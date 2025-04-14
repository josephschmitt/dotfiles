-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.diagnostic.config({ virtual_lines = true })

-- Force a specific node version for hnvm used in plugins
vim.env.HNVM_NODE = "22.14.0" -- Update this version to match your hnvm setup.
vim.env.HVNM_QUIET = false -- Ensure we log hnvm info in cases of failure.
