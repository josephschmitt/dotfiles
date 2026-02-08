return {
  "rachartier/tiny-inline-diagnostic.nvim",
  priority = 1000, -- needs to be loaded in first
  config = function()
    require("tiny-inline-diagnostic").setup({
      preset = "powerline",
      options = {
        show_source = {
          enabled = false,
          if_many = true,
        },
        use_icons_from_diagnostic = true,
        multilines = true,
      },
    })
  end,
}
