return {
  "folke/snacks.nvim",
  opts = {
    explorer = {
      replace_netrw = true,
    },
    picker = {
      hidden = true, -- Show hidden files by default
      sources = {
        explorer = {
          layout = { preset = "sidebar", preview = true }, -- Show a preview as browsing files
          actions = {
            explorer_focus = function(picker)
              vim.cmd("cd " .. picker:dir())
            end,
          },
          -- auto_close = true,
        },
        files = {
          hidden = true,
        },
      },
    },
    terminal = {
      win = {
        style = {
          height = 0.3,
        },
      },
    },
  },
}
