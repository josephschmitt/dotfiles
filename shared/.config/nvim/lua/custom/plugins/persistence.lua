-- persistence.nvim: auto-save and restore sessions per working directory.
-- Sessions are saved on exit and can be restored from the dashboard or via commands.
-- Integrates with Snacks dashboard's session section.
return {
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
  },
}
