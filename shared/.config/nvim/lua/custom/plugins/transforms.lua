-- Transform group (gx): case manipulation, pair toggling, increment/decrement.
-- Provides single-action versions of Vim's case operators (gu/gU/g~) that
-- act on the word under the cursor, plus pair toggling (true/false, &&/||)
-- and number increment/decrement with memorable keybindings.

-- Word pairs are matched case-insensitively and the replacement adopts the
-- casing of whatever matched, so each pair is listed once in lowercase.
-- Deliberately short: matching scans forward from the cursor, so every extra
-- entry is another chance to grab something you didn't mean.
local word_pairs = {
  { "true", "false" },
  { "yes", "no" },
  { "on", "off" },
  { "enable", "disable" },
  { "enabled", "disabled" },
}

-- Symbol pairs are matched literally. Single `+`/`-` is intentionally absent:
-- it collides with signed numbers, which are gx+/gx-'s job.
local symbol_pairs = {
  { "&&", "||" },
  { "===", "!==" },
  { "==", "!=" },
  { "<=", ">=" },
  { "++", "--" },
}

-- Give `target` the casing of `source`: UPPER, Title, or leave it alone.
-- Symbols fall through both checks and come back unchanged.
local function match_case(source, target)
  if source:lower() ~= source and source:upper() == source then
    return target:upper()
  end
  local head = source:sub(1, 1)
  if head:lower() ~= head then
    return target:sub(1, 1):upper() .. target:sub(2)
  end
  return target
end

-- Find the earliest togglable pair that the cursor sits inside or before,
-- mirroring how <C-a> reaches forward for the next number on the line.
-- `cursor_col` is 1-based. Returns { s, e, replacement } or nil.
local function find_target(line, cursor_col)
  local lower = line:lower()
  local best

  local function consider(s, e, replacement)
    -- Earliest start wins; on a tie the longest match wins, so `===` is
    -- preferred over the `==` sitting inside it.
    if not best or s < best.s or (s == best.s and e > best.e) then
      best = { s = s, e = e, replacement = replacement }
    end
  end

  -- First match of `needle` whose end reaches the cursor or beyond.
  local function scan(haystack, needle, plain)
    local init = 1
    while true do
      local s, e = haystack:find(needle, init, plain)
      if not s then
        return nil
      end
      if e >= cursor_col then
        return s, e
      end
      init = s + 1
    end
  end

  for _, pair in ipairs(word_pairs) do
    for i, word in ipairs(pair) do
      -- %f frontiers keep `enable` from matching inside `enabled`.
      local s, e = scan(lower, "%f[%w_]" .. word .. "%f[^%w_]", false)
      if s then
        consider(s, e, match_case(line:sub(s, e), pair[3 - i]))
      end
    end
  end

  for _, pair in ipairs(symbol_pairs) do
    for i, symbol in ipairs(pair) do
      local s, e = scan(line, symbol, true)
      if s then
        consider(s, e, pair[3 - i])
      end
    end
  end

  return best
end

-- Splice the replacement in via the API rather than `ciw`, which would
-- clobber the unnamed register and leave a stray insert on the undo stack.
local function toggle_pair()
  local pos = vim.api.nvim_win_get_cursor(0)
  local row, col = pos[1], pos[2]
  local line = vim.api.nvim_get_current_line()
  local target = find_target(line, col + 1)

  if not target then
    vim.notify("No pair to toggle at or after the cursor", vim.log.levels.WARN)
    return
  end

  -- nvim_buf_set_text takes a 0-based row and an end-exclusive column.
  vim.api.nvim_buf_set_text(0, row - 1, target.s - 1, row - 1, target.e, { target.replacement })
  -- Land on the last character of the result, the way <C-a> does.
  vim.api.nvim_win_set_cursor(0, { row, target.s - 2 + #target.replacement })
end

-- Route the toggle through 'operatorfunc' + `g@l` so `.` repeats it. Without
-- this, `.` would replay the raw edit instead of re-toggling.
_G.__transform_toggle_pair = toggle_pair

local function toggle_pair_repeatable()
  vim.go.operatorfunc = "v:lua.__transform_toggle_pair"
  vim.cmd("normal! g@l")
end

return {
  {
    "folke/which-key.nvim",
    keys = {
      { "gxu", "guiw", desc = "Lowercase word", remap = true },
      { "gxU", "gUiw", desc = "Uppercase word", remap = true },
      { "gx~", "g~iw", desc = "Toggle case word", remap = true },
      { "gxt", toggle_pair_repeatable, desc = "Toggle pair (true/false, &&/||)" },
      { "gx+", "<C-a>", desc = "Increment number" },
      { "gx-", "<C-x>", desc = "Decrement number" },
    },
  },
}
