return {
  "olimorris/codecompanion.nvim",
  -- enabled = not vim.g.vscode,
  enabled = false,
  opts = {
    copilot = function()
      return require("codecompanion.adapters").extend("copilot", {
        schema = {
          model = {
            default = "gpt-4.1",
          },
        },
      })
    end,
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
}
