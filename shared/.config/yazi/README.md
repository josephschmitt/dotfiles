# Yazi Configuration

Modern terminal file manager configuration with Catppuccin theming and enhanced functionality.

## Initial Setup
```sh
$ ya pkg install
```

## Overview

Yazi is a blazing fast terminal file manager written in Rust. This configuration provides:
- **Catppuccin Mocha theme** for consistent dark mode aesthetics
- **Auto-layout plugin** for intelligent column sizing
- **Hidden file visibility** for complete file system access
- **Custom opener configurations** for seamless editor integration

## Features

### Visual Configuration
- **Column layout**: 2:3:5 ratio for optimal file browsing
- **Hidden files**: Always visible for development work
- **Catppuccin theming**: Consistent with other dotfile tools
- **Auto-layout**: Dynamic column sizing based on content

### File Operations
- **Editor integration**: Opens files with `$EDITOR` environment variable
- **Cross-platform**: Supports both Unix and Windows systems
- **Non-blocking**: Editor opens without blocking yazi interface

## File Structure

```
.config/yazi/
├── yazi.toml           # Main configuration
├── theme.toml          # Theme settings
├── init.lua            # Lua initialization script
├── package.toml        # Plugin and flavor dependencies
├── flavors/            # Color schemes
│   └── catppuccin-mocha.yazi/
└── plugins/            # Functionality extensions
    └── auto-layout.yazi/
```

## Configuration Details

### Manager Settings (`yazi.toml`)
- **Ratio**: `[2, 3, 5]` - Balanced column layout
- **Show hidden**: `true` - Display dotfiles and hidden directories
- **Flavor**: `catppuccin-mocha` - Dark theme variant

### Theme (`theme.toml`)
- **Dark mode**: Uses Catppuccin Mocha flavor
- **Consistent styling**: Matches tmux, helix, and other tools

### Plugins (`package.toml`)
- **auto-layout**: Automatically adjusts column widths
- **catppuccin-mocha**: Official Catppuccin flavor

## Usage

### Basic Navigation
- `h/j/k/l` - Vim-style navigation
- `Enter` - Enter directory or open file
- `Backspace` - Go to parent directory
- `gg/G` - Go to top/bottom
- `/` - Search files

### File Operations
- `y` - Copy (yank) files
- `x` - Cut files
- `p` - Paste files
- `d` - Delete files
- `r` - Rename file
- `n` - Create new file
- `N` - Create new directory

### View Options
- `z` - Toggle hidden files
- `t` - Toggle preview
- `T` - Toggle layout
- `s` - Sort options
- `S` - Sort direction

### Integration
- **Helix**: Integrated via `space + e/E` keybindings
- **Terminal**: Can be launched standalone with `yazi`
- **Scripts**: Used by various shell functions and editor plugins

## Plugins

### Auto-layout
- **Purpose**: Dynamically adjusts column widths based on content
- **Benefit**: Optimal space usage for different directory structures
- **Source**: Custom fork with enhancements

### Catppuccin Mocha
- **Purpose**: Provides consistent theming across all tools
- **Colors**: Warm, dark palette optimized for long coding sessions
- **Integration**: Matches tmux, helix, and terminal themes

## Customization

### Adding New Openers
Edit `yazi.toml` to add custom file type handlers:
```toml
[opener]
image = [
  { run = 'open "$@"', for = "macos" },
]
```

### Installing Plugins
Add to `package.toml`:
```toml
[[plugin.deps]]
use = "username/plugin-name"
rev = "commit-hash"
```

### Custom Keybindings
Create `keymap.toml` for custom key mappings:
```toml
[manager]
keymap = [
  { on = [ "q" ], run = "quit" },
]
```

## Dependencies

- **Yazi**: Modern terminal file manager
- **Nerd Font**: For proper icon display
- **fd**: Fast file finding (optional, for better search)
- **ripgrep**: Fast text search (optional, for content search)

## Integration Points

- **Helix editor**: File picker integration
- **Shell functions**: Directory navigation helpers
- **Terminal workflows**: Quick file management during development
