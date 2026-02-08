local M = {}

-- Convert between POSIX and Fish shell syntax
-- POSIX: export VAR=value → Fish: set -x VAR value
-- Fish: set -x VAR value → POSIX: export VAR=value
function M.convert_shell_syntax()
  local buf = vim.api.nvim_get_current_buf()
  local start_line = vim.fn.line("'<") - 1  -- Convert to 0-indexed
  local end_line = vim.fn.line("'>") - 1    -- Convert to 0-indexed

  -- Handle reverse selection (end before start)
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  local lines = vim.api.nvim_buf_get_lines(buf, start_line, end_line + 1, false)
  local converted_lines = {}

  for _, line in ipairs(lines) do
    -- Try POSIX to Fish conversion: export VAR=value → set -x VAR value
    local converted = line:gsub("^(%s*)export%s+([A-Za-z_][A-Za-z0-9_]*)=(.*)$", "%1set -x %2 %3")

    if converted == line then
      -- Try Fish to POSIX conversion: set -x VAR value → export VAR=value
      converted = line:gsub("^(%s*)set%s+-x%s+([A-Za-z_][A-Za-z0-9_]*)%s+(.*)$", "%1export %2=%3")
    end

    table.insert(converted_lines, converted)
  end

  vim.api.nvim_buf_set_lines(buf, start_line, end_line + 1, false, converted_lines)
end

return M
