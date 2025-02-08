-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set

-- Undo/redo
map({ "n", "v" }, "U", "<C-r>", { desc = "Redo" })

-- Goto commands
map({ "n", "v" }, "gh", "^", { desc = "Go to beginning of line" })
map({ "n", "v" }, "gl", "$", { desc = "Go to end of line" })

-- Window commands
-- map({ "n" }, "<A-h>", "<C-w>h", { desc = "Go to the left window" })
-- map({ "n" }, "<A-l>", "<C-w>l", { desc = "Go to the right window" })
-- map({ "n" }, "<A-j>", "<C-w>j", { desc = "Go to the down window" })
-- map({ "n" }, "<A-k>", "<C-w>k", { desc = "Go to the up window" })
-- map({ "n" }, "<A-w>", "<C-w>w", { desc = "Switch windows" })
map({ "n" }, "<A-s>", "<C-w>s", { desc = "Split window" })
map({ "n" }, "<A-v>", "<C-w>v", { desc = "Split window vertically" })

map({ "n" }, "<C-a>", "ggVG", { desc = "Select all" })
