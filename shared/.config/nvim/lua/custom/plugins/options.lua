-- Custom vim options that override kickstart defaults.
-- These run when lazy.nvim loads this file, before VimEnter.

-- Relative line numbers for easy jump counting (kickstart only enables number)
vim.o.relativenumber = true

-- Disable line wrapping (toggleable with <Leader>tw)
vim.o.wrap = false

return {}
