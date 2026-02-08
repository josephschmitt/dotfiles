-- Override kickstart's tokyonight config with moon style.
-- When lazy.nvim sees the same plugin in multiple specs, it merges them —
-- so this overrides the config function from init.lua's stock tokyonight spec.
return {
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "moon",
      transparent = false,
      terminal_colors = true,
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight-moon")
    end,
  },
}
