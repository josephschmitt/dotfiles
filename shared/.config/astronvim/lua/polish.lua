-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Configure tokyonight to match LazyVim's lighter appearance
require("tokyonight").setup({
  style = "moon",
  transparent = false,
  terminal_colors = true,
})

-- Set tokyonight as the active colorscheme
vim.cmd.colorscheme "tokyonight-moon"
