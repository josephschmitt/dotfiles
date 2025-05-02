-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.diagnostic.config({ virtual_lines = true })

-- Force a specific node version for hnvm used in plugins
vim.env.HNVM_NODE = "22.14.0" -- Update this version to match your hnvm setup.
vim.env.HVNM_QUIET = false -- Ensure we log hnvm info in cases of failure.

vim.opt.guicursor = {
  "n-v-c:block", -- Normal, visual, and command mode: block cursor
  "v:hor10", -- Override visual mode: horizontal line (underscore)
  "i-ci:ver25", -- Insert and command-insert: vertical bar
  "r-cr:hor20", -- Replace and command-replace: horizontal bar
  "o:hor50", -- Operator-pending: thick horizontal
}
