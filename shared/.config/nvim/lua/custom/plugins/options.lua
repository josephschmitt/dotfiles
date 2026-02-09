-- Custom vim options that override kickstart defaults.
-- These run when lazy.nvim loads this file, before VimEnter.

-- Relative line numbers for easy jump counting (kickstart only enables number)
vim.o.relativenumber = true

-- Disable line wrapping (toggleable with <Leader>tw)
vim.o.wrap = false

-- RPC server: create a socket so external tools (terminal popups, git
-- commit editors, etc.) can open files in this running Neovim instance.
-- Socket path: ~/.local/state/nvim/nvim.<pid>.sock
local socket_path = vim.fn.stdpath("state") .. "/nvim." .. vim.fn.getpid() .. ".sock"
pcall(vim.fn.serverstart, socket_path)

return {}
