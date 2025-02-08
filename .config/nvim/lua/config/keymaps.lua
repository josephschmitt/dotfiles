-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set

map({ "n", "i", "v" }, "U", "<C-r>", { desc = "Redo" })

map({ "n", "i", "v" }, "gh", "^", { desc = "Go to beginning of line" })
map({ "n", "i", "v" }, "gl", "$", { desc = "Go to end of line" })
