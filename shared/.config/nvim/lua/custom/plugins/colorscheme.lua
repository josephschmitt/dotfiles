-- Override kickstart's tokyonight config with moon style.
-- When lazy.nvim sees the same plugin in multiple specs, it merges them —
-- so this overrides the config function from init.lua's stock tokyonight spec.

local function set_custom_highlights()
  -- Blue window separators (matches tokyonight-moon accent color)
  vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#7aa2f7", bg = "NONE", bold = true })
  -- Subtle color column background
  vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#292e42" })
end

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

      -- Show vertical line at column 100
      vim.opt.colorcolumn = "100"

      -- Nicer split border characters
      vim.opt.fillchars:append({ vert = "│", horiz = "─", horizup = "┴", horizdown = "┬" })

      -- Apply custom highlights now and after any colorscheme change
      set_custom_highlights()
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("custom-highlights", { clear = true }),
        callback = set_custom_highlights,
      })
    end,
  },
}
