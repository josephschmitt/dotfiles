-- mason-auto-install: automatically installs Mason packages (LSP servers,
-- formatters, etc.) when you open a filetype that needs them.
-- Reads filetypes from lspconfig so no manual package list is needed.
-- https://github.com/owallb/mason-auto-install.nvim
return {
  "owallb/mason-auto-install.nvim",
  dependencies = {
    "mason-org/mason.nvim",
    "neovim/nvim-lspconfig",
  },
  opts = {},
}
