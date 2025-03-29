-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set

-- Undo/redo
map({ "n", "v" }, "U", "<C-r>", { desc = "Redo" })

-- Goto commands
map({ "n", "v" }, "gs", "^", { desc = "Go to line first non-blank character" })
map({ "n", "v" }, "gh", "0", { desc = "Go to beginning of line" })
map({ "n", "v" }, "gl", "$", { desc = "Go to end of line" })
map({ "n", "v" }, "ge", "G", { desc = "Go to last line" })
map({ "n", "v" }, "gj", "G", { desc = "Go to last line" })
map({ "n", "v" }, "gk", "gg", { desc = "Go to first line" })

-- Window commands
map({ "n" }, "<A-s>", "<C-w>s", { desc = "Split window" })
map({ "n" }, "<A-v>", "<C-w>v", { desc = "Split window vertically" })

-- Helix-like line selection and delete
map({ "n" }, "<C-a>", "ggVG", { desc = "Select all" })
map({ "n" }, "%", "ggVG", { desc = "Select all" })
map({ "n" }, "x", "V", { desc = "Select line" })
map({ "n" }, "d", "x", { desc = "Delete character" })

map({ "v" }, "x", "j", { desc = "Select next line" })
map({ "v" }, "X", "k", { desc = "Select prev line" })
