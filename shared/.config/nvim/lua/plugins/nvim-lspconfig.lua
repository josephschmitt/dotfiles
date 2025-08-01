return {
  "neovim/nvim-lspconfig",
  opts = {
    -- Using tiny-inline-diagnostics
    diagnostics = {
      virtual_text = false,
      virtual_lines = false,
    },
    servers = { eslint = {} },
    setup = {
      eslint = function()
        require("lazyvim.util").lsp.on_attach(function(client)
          if client.name == "eslint" then
            client.server_capabilities.documentFormattingProvider = true
          elseif client.name == "tsserver" then
            client.server_capabilities.documentFormattingProvider = false
          end
        end)
      end,
    },
  },
}
