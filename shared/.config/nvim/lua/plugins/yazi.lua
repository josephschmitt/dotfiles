return {
  "mikavilpas/yazi.nvim",
  dependencies = {
    "folke/snacks.nvim",
  },
  keys = {
    {
      "<leader>fy",
      mode = { "n", "v" },
      "<cmd>Yazi<cr>",
      desc = "Yazi (current file)",
    },
    {
      "<leader>y",
      mode = { "n", "v" },
      "<cmd>Yazi<cr>",
      desc = "Yazi (current file)",
    },
    {
      "<leader>fY",
      "<cmd>Yazi cwd<cr>",
      desc = "Yazi (cwd)",
    },
    {
      "<leader>Y",
      "<cmd>Yazi cwd<cr>",
      desc = "Yazi (cwd)",
    },
  },
  ---@type YaziConfig
  opts = {
    floating_window_scaling_factor = 0.8,
  },
}
