# Eza Configuration

Configuration for [eza](https://eza.rocks) - a modern replacement for `ls` with color-coding, icons, and enhanced file information display.

## Features

- **Color-coded file types** and permissions
- **Git integration** shows file status in repository directories
- **Icons** for file types (with Nerd Font support)
- **Tree view** for recursive directory listing
- **Multiple themes** included (Catppuccin, Tokyo Night)

## File Structure

- `theme.yml` - Active theme configuration (symlinked)
- `catppuccin.yml` - Catppuccin Mocha color scheme
- `tokyonight.yml` - Tokyo Night color scheme

## Color Scheme

The themes provide consistent color coding for:
- **Directories** - Blue
- **Executables** - Green
- **Symlinks** - Cyan
- **Permissions** - Different colors for read/write/execute
- **Git status** - Modified, staged, untracked files

## Shell Integration

Eza is aliased to replace `ls` in the shell configuration:

```fish
alias ls='eza'
alias ll='eza -l'
alias la='eza -la'
alias lt='eza --tree'
```

## Common Usage

```bash
# Basic listing with icons
eza

# Long format with details
eza -l

# Show all files including hidden
eza -la

# Tree view with depth limit
eza --tree --level=2

# Git-aware listing
eza -l --git
```

## Installation

Installed via main dotfiles setup:

```bash
stow shared
```

## Dependencies

- **eza** - The eza command-line tool
- **Nerd Font** - For icon display

## Theme Switching

To switch between themes, update the symlink:

```bash
cd ~/.config/eza
ln -sf catppuccin.yml theme.yml
# or
ln -sf tokyonight.yml theme.yml
```
