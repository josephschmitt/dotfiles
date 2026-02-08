return {
  -- ASCII art library for dashboard header
  { "MaximilianLloyd/ascii.nvim" },

  -- Snacks.nvim dashboard
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {},
      },
    },
    config = function(_, opts)
      -- Load ascii art and set as header
      local ok, ascii = pcall(require, "ascii")
      if ok then
        local art = ascii.art.text.neovim.ansi_shadow
        if art then
          if type(art) == "table" then art = table.concat(art, "\n") end
          opts.dashboard.preset.header = art
        end
      end
      require("snacks").setup(opts)
    end,
  },
}
