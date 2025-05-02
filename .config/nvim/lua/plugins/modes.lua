local colors = require("tokyonight.colors").setup({ style = "night" })

return {
  "mvllow/modes.nvim",
  opts = {
    colors = {
      copy = colors.orange,
      delete = colors.red,
      insert = colors.green,
      visual = "#e178fa",
    },

    -- Set opacity for cursorline and number background
    line_opacity = 0.15,

    -- Enable cursor highlights
    set_cursor = true,

    -- Enable cursorline initially, and disable cursorline for inactive windows
    -- or ignored filetypes
    set_cursorline = true,

    -- Enable line number highlights to match cursorline
    set_number = true,

    -- Enable sign column highlights to match cursorline
    set_signcolumn = true,
  },
}
