# Fish Shell Configuration

Configuration for [Fish](https://fishshell.com) - a modern, user-friendly shell with powerful features and sensible defaults.

## Features

- **Vi-mode keybindings** with custom cursor shapes per mode
- **Auto-start tmux** on interactive shells (skips VS Code/IDE terminals)
- **Oh-My-Posh prompt** integration for consistent theming
- **FZF integration** for fuzzy finding (history, files, directories)
- **Zoxide integration** for smart directory jumping
- **Custom completions** for various CLI tools

## File Structure

- `config.fish` - Main configuration and interactive shell setup
- `env.fish` - Environment variables and PATH configuration
- `aliases.fish` - Shell aliases
- `functions/` - Custom Fish functions
- `completions/` - Custom completion definitions
- `conf.d/` - Additional configuration files loaded automatically
- `fish_plugins` - Fisher plugin list

## Key Features

### Vi-Mode Keybindings

Fish is configured with vi-mode by default with custom keybindings:
- `Shift+U` - Redo
- `gh` - Jump to beginning of line
- `gl` - Jump to end of line
- Different cursor shapes for insert/normal/visual modes

**Mode Indicator**: The current vim mode is displayed in the oh-my-posh prompt on the same line as the prompt arrow using nerd font icons:
- 󰫶 ❯ - Insert mode (green)
- 󰫻 ❯ - Normal mode (blue)
- 󰬃 ❯ - Visual mode (lavender)
- 󰫿 ❯ - Replace mode (pink)

The indicator updates immediately when switching modes via the `rerender_on_bind_mode_change` function which bridges Fish's `$fish_bind_mode` to oh-my-posh.

### FZF Integration

Provides fuzzy finding for:
- Command history (`Ctrl+R`)
- File navigation
- Directory search
- Git operations
- Process selection

### Custom Functions

Notable functions in `functions/`:
- `cdd` - Quick cd to `~/development/$argv`
- `auto_start_tmux` - Automatically start/attach tmux sessions
- Various FZF wrapper functions for enhanced workflows

## Installation

Fish shell is installed via the main dotfiles setup:

```bash
stow shared
```

### Plugin Manager

This configuration uses [Fisher](https://github.com/jorgebucaran/fisher) for plugin management. Install plugins with:

```bash
fisher update
```

## Dependencies

- **oh-my-posh** - Prompt theming
- **fzf** - Fuzzy finder
- **zoxide** - Smart directory navigation
- **fisher** - Plugin manager

## Usage

Fish becomes the default shell after installation. Key integrations:
- Automatically starts tmux for interactive sessions
- Integrates with FZF for fuzzy finding throughout the shell
- Works seamlessly with Zoxide for directory navigation
