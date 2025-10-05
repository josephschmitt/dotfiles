return {
  "neovim/nvim-lspconfig",
  opts = {
    diagnostics = {
      virtual_text = false,
      virtual_lines = false,
    },
    servers = {
      eslint = {},
      nil_ls = {},
    },
    setup = {
      eslint = function()
        LazyVim.lsp.on_attach(function(client)
          if client.name == "eslint" then
            client.server_capabilities.documentFormattingProvider = true
          elseif client.name == "tsserver" then
            client.server_capabilities.documentFormattingProvider = false
          end
        end)
      end,
      nil_ls = function()
        LazyVim.lsp.on_attach(function(client)
          if client.name == "nil_ls" then
            client.server_capabilities.documentFormattingProvider = false
          end
        end)
      end,
    },
  },
}
