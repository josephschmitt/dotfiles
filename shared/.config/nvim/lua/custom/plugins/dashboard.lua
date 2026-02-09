return {
  -- ASCII art library for dashboard header
  { "MaximilianLloyd/ascii.nvim" },

  -- Snacks.nvim dashboard (setup() is called in picker.lua's config)
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {},
      },
    },
  },
}
