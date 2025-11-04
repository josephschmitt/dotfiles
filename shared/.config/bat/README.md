# Bat Configuration

Configuration for [bat](https://github.com/sharkdp/bat) - a cat clone with syntax highlighting and Git integration.

## Theme

Uses the Tokyo Night theme variants from [tokyonight.nvim](https://github.com/folke/tokyonight.nvim):

- `tokyonight_night` (default, set via `BAT_THEME` environment variable)
- `tokyonight_storm`
- `tokyonight_moon`
- `tokyonight_day`

Theme files are located in `themes/` and are automatically loaded when bat is installed via Stow.

## Installation

After stowing, rebuild the bat cache to load the themes:

```bash
bat cache --build
```

## Usage

Bat is used throughout the dotfiles for:
- File previews in fzf
- Syntax highlighting in tmux popups (ripgrep search)
- General file viewing with `bat <file>`
