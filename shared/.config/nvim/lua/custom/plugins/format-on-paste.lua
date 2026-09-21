-- Auto-format pasted text via conform.nvim.
-- conform has no native "format on paste" option, so this pastes normally
-- then formats just the pasted range using the '[/'] marks Neovim sets
-- after any put operation.
local function format_pasted_range()
  local start_line = vim.api.nvim_buf_get_mark(0, "[")[1]
  local end_line = vim.api.nvim_buf_get_mark(0, "]")[1]
  local end_col = #(vim.api.nvim_buf_get_lines(0, end_line - 1, end_line, false)[1] or "")
  require("conform").format({
    range = {
      start = { start_line, 0 },
      ["end"] = { end_line, end_col },
    },
  })
end

local function normal_paste(key)
  return function()
    vim.cmd("normal! " .. vim.v.count1 .. '"' .. vim.v.register .. key)
    format_pasted_range()
  end
end

-- Visual paste must leave visual mode (<Esc>) before re-selecting with gv,
-- otherwise nvim_get_mode() stays stuck in "V" and the paste never applies.
local function visual_paste(key)
  return function()
    vim.cmd('normal! \27gv"' .. vim.v.register .. key)
    format_pasted_range()
  end
end

return {
  {
    "stevearc/conform.nvim",
    keys = {
      { "p", normal_paste("p"), mode = "n", desc = "Paste and format" },
      { "P", normal_paste("P"), mode = "n", desc = "Paste and format" },
      { "p", visual_paste("p"), mode = "v", desc = "Paste and format" },
      { "P", visual_paste("P"), mode = "v", desc = "Paste and format" },
    },
  },
}
