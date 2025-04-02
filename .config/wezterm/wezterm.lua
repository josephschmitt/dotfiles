local wezterm = require 'wezterm'
local config = {}

config.font = wezterm.font('FiraCode Nerd Font Mono', { weight = "Medium" })
config.font_size = 13.25
config.line_height = 1.2
config.color_scheme = "Catppuccin Mocha"
config.use_fancy_tab_bar = false
-- config.tab_max_width = 100

local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
tabline.setup()
-- tabline.apply_to_config(config)


config.keys = {
  {
    key = 'h',
    mods = 'ALT',
    action = wezterm.action.ActivatePaneDirection 'Left',
  },
  {
    key = 'j',
    mods = 'ALT',
    action = wezterm.action.ActivatePaneDirection 'Down',
  },
  {
    key = 'k',
    mods = 'ALT',
    action = wezterm.action.ActivatePaneDirection 'Up',
  },
  {
    key = 'l',
    mods = 'ALT',
    action = wezterm.action.ActivatePaneDirection 'Right',
  },
}

return config
