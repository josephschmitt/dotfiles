return {
  "neovim/nvim-lspconfig",
  opts = {
    diagnostics = {
      virtual_text = false,
      virtual_lines = false,
    },
    servers = {
      eslint = {},
    },
  },
  init = function()
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then
          return
        end
        if client.name == "eslint" then
          client.server_capabilities.documentFormattingProvider = true
        elseif client.name == "tsserver" then
          client.server_capabilities.documentFormattingProvider = false
        end
      end,
    })
  end,
}
