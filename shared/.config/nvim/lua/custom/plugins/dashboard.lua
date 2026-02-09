return {
  -- ASCII art library for dashboard header
  { "MaximilianLloyd/ascii.nvim" },

  -- Snacks.nvim dashboard (setup() is called in picker.lua's config)
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          keys = {
            { icon = "󰈔 ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = "󰮯 ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = "󰊄 ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = "󰟨 ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            { icon = "󰮯 ", key = "p", desc = "Find Project", action = ":Pj" },
            { icon = "󰋚 ", key = "s", desc = "Restore Session", section = "session" },
            { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
            { icon = "󰈆 ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
      },
    },
  },
}
