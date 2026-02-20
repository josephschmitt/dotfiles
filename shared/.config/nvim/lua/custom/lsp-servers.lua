-- LSP servers to enable.
-- Each key is an lspconfig server name, value is server-specific config.
-- mason-auto-install will download these automatically on first use.
return {
  ts_ls = {}, -- TypeScript, JavaScript, React (JSX/TSX)
  jsonls = {}, -- JSON
  yamlls = {}, -- YAML
  gopls = {}, -- Go
  rust_analyzer = {}, -- Rust
  marksman = {}, -- Markdown
}
