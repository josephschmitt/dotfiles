-- Auto-installs the non-LSP formatters conform.nvim expects (see
-- formatters_by_ft in init.lua). mason-auto-install.lua only handles LSP
-- servers; mason-tool-installer.nvim covers everything else Mason manages.
--
-- init.lua calls mason-tool-installer's .setup() directly inside its own
-- config function (with an empty ensure_installed), instead of using lazy.nvim
-- `opts` — so an `opts` override here can't merge into it, and this must load
-- eagerly (not lazy-loaded via keys/cmd/event) because mason-tool-installer's
-- own plugin/ script fires the actual install check on VimEnter. If our
-- .setup() call ran any later than init.lua's, the install check would
-- already be done for the session by the time we added our packages.
require("mason-tool-installer").setup {
  ensure_installed = {
    "stylua", -- lua
    "gofumpt", -- go
    "prettierd", -- json, jsonc, javascript(react), typescript(react), css, html, markdown, yaml, graphql
  },
}

return {}
