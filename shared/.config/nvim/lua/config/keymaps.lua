-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set

-- Undo/redo
map({ "n", "v" }, "U", "<C-r>", { desc = "Redo" })

-- Allow clipboard copy paste in neovim
if vim.g.neovide then
  map("n", "<D-s>", ":w<CR>") -- Save
  map("v", "<D-c>", '"+y') -- Copy
  map("n", "<D-v>", '"+P') -- Paste normal mode
  map("v", "<D-v>", '"+P') -- Paste visual mode
  map("c", "<D-v>", "<C-R>+") -- Paste command mode
  map("i", "<D-v>", '<ESC>l"+Pli') -- Paste insert mode
end

-- Allow clipboard copy paste in neovim
vim.api.nvim_set_keymap("", "<D-v>", "+p<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("!", "<D-v>", "<C-R>+", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<D-v>", "<C-R>+", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<D-v>", "<C-R>+", { noremap = true, silent = true })

-- Leader
map({ "n", "v" }, "<leader>X", "<cmd>:LazyExtras<CR>", { desc = "Open Lazy Extras" })

-- Comment line
map({ "n" }, "<C-c>", "gcc", { remap = true, desc = "Comment line" })
map({ "v" }, "<C-c>", "gc", { remap = true, desc = "Comment line" })

-- Indent line
map({ "n" }, "<", "<<", { remap = true, desc = "Unindent line" })
map({ "n" }, ">", ">>", { remap = true, desc = "Indent line" })

-- Goto commands
map({ "n", "v" }, "gh", "0", { desc = "Go to beginning of line" })
map({ "n", "v" }, "gl", "$", { desc = "Go to end of line" })

-- Window commands
map({ "n", "v" }, "gw", "<C-w>", { desc = "Window mode" })
map({ "n" }, "<A-s>", "<C-w>s", { desc = "Split window" })
map({ "n" }, "<A-v>", "<C-w>v", { desc = "Split window vertically" })
map({ "n" }, "<A-q>", "<C-w>q", { desc = "Close window" })
map({ "n" }, "<A-o>", "<C-w>o", { desc = "Close other window" })
map({ "n" }, "<A-w>", "<C-w>w", { desc = "Switch window" })

-- Helix-like line selection and delete
map({ "n" }, "<C-a>", "ggVG", { desc = "Select all" })
map({ "v" }, "<S-v>", "j", { desc = "Select down" })

-- map({ "n" }, "x", "V", { desc = "Select line" })
-- map({ "n" }, "d", "x", { desc = "Delete character" })

-- map({ "v" }, "x", "j", { desc = "Select next line" })
-- map({ "v" }, "X", "k", { desc = "Select prev line" })

-- Exit insert mode
map({ "i" }, "jk", "<esc>", { desc = "Exit insert mode" })
map({ "i" }, "kj", "<esc>", { desc = "Exit insert mode" })
map({ "i" }, "jj", "<esc>", { desc = "Exit insert mode" })

-- Buffers
map({ "n", "v" }, "<leader>ba", "<cmd>bufdo bd<cr>", { desc = "Close all buffers" })
-- Switch buffer that also works in insert mode
-- map({ "n", "i", "v" }, "<A-h>", "<Cmd>bprevious<CR>", { desc = "Previous buffer" })
-- map({ "n", "i", "v" }, "<A-l>", "<Cmd>bnext<CR>", { desc = "Next buffer" })
-- Map Ctrl-0 to go to the last visible buffer
map({ "n", "i", "v" }, "<C-0>", function()
  local count = #vim.fn.getbufinfo({ buflisted = 1 })
  vim.cmd(("BufferLineGoToBuffer %d"):format(count))
end, { desc = "Go to last buffer" })
for i = 1, 9 do
  map({ "n", "i", "v" }, ("<C-%d>"):format(i), ("<Cmd>BufferLineGoToBuffer %d<CR>"):format(i), {
    desc = ("Go to buffer %d"):format(i),
  })
end

-- CodeCompanion
map({ "n", "v" }, "<leader>C", "", { noremap = true, silent = true, desc = "+codecompanion" })
map({ "n", "v" }, "<leader>Cc", "<cmd>CodeCompanion<cr>", { desc = "Code Companion" })
map({ "n", "v" }, "<leader>CC", "<cmd>CodeCompanionChat<cr>", { desc = "Code Companion" })
map({ "n", "v" }, "<leader>Ca", "<cmd>CodeCompanionActions<cr>", { desc = "Code Companion" })
