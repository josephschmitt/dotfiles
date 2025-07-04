# Zellij Configuration

Terminal multiplexer configuration with custom keybindings, plugins, and Catppuccin theming.

## Overview

Zellij is a modern terminal workspace with built-in multiplexing, session management, and plugin ecosystem. This configuration provides:

- **Custom keybindings** with vim-style navigation
- **tmux compatibility mode** for familiar workflows  
- **Plugin ecosystem** for enhanced functionality
- **Catppuccin theming** for consistent visual design
- **Auto-lock functionality** to prevent accidental input

## Key Features

### Navigation & Modes
- **Vim-style navigation** (`hjkl` keys) across panes and tabs
- **tmux compatibility** mode with `Ctrl-b` prefix
- **Multiple modes**: normal, pane, tab, resize, move, scroll, search
- **Auto-lock** when entering vim, git, or other focused applications

### Plugins
- **zjstatus** - Custom status bar with git branch and datetime
- **autolock** - Automatically locks when entering specific applications
- **session-manager** - Enhanced session management
- **plugin-manager** - Easy plugin installation and management

### Theming
- **Catppuccin Macchiato** theme for consistent dark mode
- **Custom status bar** with mode indicators and session info
- **No pane frames** for cleaner appearance

## File Structure

```
.config/zellij/
├── config.kdl              # Main configuration with keybindings
├── config.no-autolock.kdl  # Alternative config without autolock
└── README.md               # This file
```

## Key Bindings

### Mode Switching
- `Ctrl-p` - Pane mode
- `Ctrl-t` - Tab mode  
- `Ctrl-n` - Resize mode
- `Ctrl-m` - Move mode
- `Ctrl-s` - Scroll mode
- `Ctrl-o` - Session mode
- `Ctrl-b` - tmux mode
- `Ctrl-g` - Lock mode

### Pane Management
- `Alt-h/j/k/l` - Navigate between panes
- `Alt-p` - New pane
- `Alt-x` - Close pane
- `Alt-z` - Toggle fullscreen
- `Alt-f` - Toggle floating panes

### Tab Management  
- `Alt-t` - New tab
- `Alt-{/}` - Previous/next tab
- `Alt-1-9` - Go to tab by number
- `Alt-i/o` - Move tab left/right

### Session Management
- `Ctrl-d` - Detach from session
- `Ctrl-q` - Quit zellij

## Plugins Configuration

### zjstatus
Custom status bar showing:
- Current mode with color coding
- Active tabs with indicators
- Session name
- Current date/time
- Git branch (when in git repository)

### autolock
Automatically locks zellij when entering:
- `nvim`, `vim` - Text editors
- `git` - Git commands
- `fzf` - Fuzzy finder
- `zoxide` - Directory jumper
- `atuin` - Shell history

## Usage Tips

1. **Start a session**: `zellij` or `zellij attach <session-name>`
2. **Detach safely**: `Ctrl-d` (preserves session)
3. **Quick navigation**: Use `Alt` + direction keys for fast pane switching
4. **tmux users**: Use `Ctrl-b` to enter tmux-compatible mode
5. **Plugin management**: `Ctrl-o` then `p` to open plugin manager

## Customization

- **Keybindings**: Modify the `keybinds` section in `config.kdl`
- **Theme**: Change `theme` value or customize colors in zjstatus plugin
- **Plugins**: Add new plugins in the `plugins` section
- **Auto-lock**: Adjust triggers in the autolock plugin configuration