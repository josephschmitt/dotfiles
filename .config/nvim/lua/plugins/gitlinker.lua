return {
  "ruifm/gitlinker.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("gitlinker").setup()
  end,
  keys = {
    {
      "<leader>gy",
      mode = { "n", "v" },
      function()
        require("gitlinker").get_buf_range_url("n")
      end,
      desc = "Copy GitHub permalink",
    },
  },
}
