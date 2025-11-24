-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set

-- Undo/redo
map({ "n", "v" }, "U", "<C-r>", { desc = "Redo" })

-- Allow clipboard copy paste in neovim
vim.api.nvim_set_keymap("", "<D-v>", "+p<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("!", "<D-v>", "<C-R>+", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<D-v>", "<C-R>+", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<D-v>", "<C-R>+", { noremap = true, silent = true })

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
map({ "n" }, "<A-w>", "<C-w>w", { desc = "Switch window" })

-- Helix-like line selection and delete
map({ "v" }, "<S-v>", "j", { desc = "Select down" })
map({ "n" }, "<C-a>", function()
  local ok, animate = pcall(require, "mini.animate")
  if ok then
    local config = animate.config
    animate.config.scroll = { enable = false }
    vim.cmd("normal! ggVG")
    animate.config = config
  else
    vim.cmd("normal! ggVG")
  end
end, { desc = "Select all" })
map({ "n" }, "gV", "ggVG", { desc = "Select all" })

-- Exit insert mode
map({ "i" }, "jk", "<esc>", { desc = "Exit insert mode" })
map({ "i" }, "kj", "<esc>", { desc = "Exit insert mode" })
map({ "i" }, "jj", "<esc>", { desc = "Exit insert mode" })

-- Buffers
map({ "n", "v" }, "<leader>ba", function()
  -- Get all buffers and close only regular file buffers
  local bufs = vim.api.nvim_list_bufs()
  for _, buf in ipairs(bufs) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
      local buftype = vim.bo[buf].buftype
      -- Only delete normal file buffers, not special buffers
      if buftype == "" then
        vim.api.nvim_buf_delete(buf, { force = false })
      end
    end
  end

  require("snacks").dashboard({ focus = true })
end, { desc = "Close all buffers" })

-- Dashboard
map({ "n" }, "<leader>uB", function()
  require("snacks").dashboard()
end, { desc = "Show Dashboard" })
