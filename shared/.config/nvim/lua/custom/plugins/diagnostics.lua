-- tiny-inline-diagnostic.nvim: prettier inline diagnostics with powerline style.
-- Replaces Neovim's default virtual_text diagnostics with styled, multiline-aware ones.
-- The plugin automatically disables virtual_text when loaded.
return {
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    priority = 1000,
    opts = {
      preset = "powerline",
      options = {
        show_source = {
          enabled = false,
          if_many = true,
        },
        use_icons_from_diagnostic = true,
        multilines = true,
      },
    },
  },
}
