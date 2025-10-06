# Ghostty Terminal Configuration

Configuration for [Ghostty](https://ghostty.org) - a fast, native, GPU-accelerated terminal emulator for macOS.

## Features

- **GPU acceleration** for smooth rendering
- **Native macOS integration** with proper font rendering
- **Quick terminal** with global hotkey access
- **Split panes** with vim-like navigation
- **Catppuccin Mocha theme** with Tokyo Night available
- **Shell integration** with Fish

## Key Settings

### Appearance
- **Font**: Monaco Nerd Font Mono (13pt, thickened)
- **Theme**: Catppuccin Mocha (default)
- **Cursor**: Bar style
- **Cell height**: Adjusted +10% for better readability

### Quick Terminal
Global overlay terminal accessible from anywhere:
- **Hotkey**: `Ctrl+\`` (backtick)
- **Position**: Right side of screen
- **Size**: 500px width, 100% height
- **Animation**: 0.15s slide-in

### Split Panes
Vim-style navigation with hjkl keys:

**Navigation** (`Cmd+Alt+[hjkl]`):
- `Cmd+Alt+H` - Move to left pane
- `Cmd+Alt+J` - Move to bottom pane
- `Cmd+Alt+K` - Move to top pane
- `Cmd+Alt+L` - Move to right pane

**Creating Splits** (`Ctrl+Cmd+[hjkl]`):
- `Ctrl+Cmd+H` - New split on left
- `Ctrl+Cmd+J` - New split below
- `Ctrl+Cmd+K` - New split above
- `Ctrl+Cmd+L` - New split on right

**Resizing** (`Ctrl+Alt+[hjkl]`):
- Resize splits by 10px in each direction

**Other**:
- `Cmd+Alt+Z` - Toggle zoom current pane

### Tabs
- `Cmd+Shift+H` - Previous tab
- `Cmd+Shift+L` - Next tab
- `Cmd+Shift+W` - Close tab

## Themes

The configuration includes both Catppuccin and Tokyo Night themes:
- `themes/tokyo-night-default` - Tokyo Night color scheme
- Default theme set to Catppuccin Mocha

## Installation

Installed via main dotfiles setup:

```bash
stow shared
```

## Dependencies

- **Ghostty** - Terminal emulator (installed separately)
- **Monaco Nerd Font Mono** - Font with icon support

## Usage

Ghostty serves as the primary terminal emulator, integrating with:
- Fish shell (with shell integration enabled)
- Tmux (for advanced session management)
- Quick terminal overlay for fast command access
