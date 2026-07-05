-- mason-auto-install: automatically installs Mason packages (LSP servers,
-- formatters, etc.) when you open a filetype that needs them.
-- Filetypes are read from lspconfig automatically, but the plugin still needs
-- each server's *Mason registry* name below (which often differs from its
-- lspconfig name, e.g. `jsonls` -> `json-lsp`). When adding/removing a server
-- in lua/custom/lsp-servers.lua, update this list too.
-- https://github.com/owallb/mason-auto-install.nvim
return {
  "owallb/mason-auto-install.nvim",
  dependencies = {
    "mason-org/mason.nvim",
    "neovim/nvim-lspconfig",
  },
  opts = {
    packages = {
      "lua-language-server", -- lua_ls (enabled separately in init.lua)
      "typescript-language-server", -- ts_ls
      "json-lsp", -- jsonls
      "yaml-language-server", -- yamlls
      "gopls", -- gopls
      "rust-analyzer", -- rust_analyzer
      "marksman", -- marksman
    },
  },
}
