return {
  "folke/snacks.nvim",
  opts = {
    exporer = {
      replace_netrw = true,
    },
    picker = {
      hidden = true, -- Show hidden files by default
      sources = {
        explorer = {
          layout = { preset = "sidebar", preview = true }, -- Show a preview as browsing files
          auto_close = true,
        },
      },
    },
  },
}
