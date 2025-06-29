return {
  "ravitemer/mcphub.nvim",
  event = "VeryLazy",
  opts = {
    -- Set to true to auto-approve all MCP tool calls without confirmation
    auto_approve = false,
    extensions = {
      avante = {
        make_slash_commands = true, -- Enable /mcp:server:prompt commands in avante
      },
    },
  },
  config = function(_, opts)
    require("mcphub").setup(opts)
  end,
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
}