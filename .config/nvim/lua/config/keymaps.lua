-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

return {
  -- Swap redo and undo line
  { "n", "U", "<C-r>", { desc = "Redo" } },
  { "n", "<C-r>", "U", { desc = "Undo Line" } },

  -- Buffer fuzzy finder
  { "n", "<leader>bf", ":Telescope buffers<CR>", { desc = "Fuzzy Search Buffers" } },
}
