# Dotfiles

Personal configuration files for development environment.

## Installation

This repo uses [GNU Stow](https://www.gnu.org/software/stow/) for managing dotfiles.

### Prerequisites

Install GNU Stow:
```bash
# macOS
brew install stow

# Ubuntu/Debian
sudo apt install stow
```

### Setup

Clone this repository:
```bash
$ git clone git@github.com:josephschmitt/dotfiles.git ~/.dotfiles
$ cd ~/.dotfiles
```

#### Personal Machine
```bash
stow shared personal
```

#### Work Machine  
```bash
stow shared work
```

**Note:** Make sure to update the email in `personal/.gitconfig` before using.

## Structure

- `shared/` - Common configurations used on all machines
- `personal/` - Personal-specific configs (personal email, etc.)
- `work/` - Work-specific configs (work email, company tools, etc.)

## What's Included

### Shell Configuration
- **Fish Shell** (`.config/fish/`) - Modern shell with intelligent autocompletion
  - Custom functions and aliases
  - Git-spice integration
  - Development environment setup
  - Vi-mode keybindings

### Editor Configuration
- **Helix** (`.config/helix/`) - Modal text editor
  - Catppuccin theme
  - Custom keybindings for navigation
  - Yazi file picker integration
  - Git permalink generation

### Terminal Multiplexer
- **tmux** (`.config/tmux/`) - Terminal session management
  - Catppuccin theme
  - Plugin ecosystem (fzf, sessionx, floax)
  - Vim-style navigation
  - Session persistence

### Development Tools
- **Git** (`.gitconfig`) - Version control with custom aliases
- **Ghostty** (`.config/ghostty/`) - Terminal emulator
- **Warp** (`.warp/`) - Modern terminal with AI features

### Package Managers & Tools
- **Nix** configuration for reproducible environments
- **pnpm**, **bun**, **cargo** path configurations
- **asdf** version manager setup

## Key Features

- **Consistent theming** across all tools (Catppuccin)
- **Vi-mode everywhere** for consistent navigation
- **Fuzzy finding** integration (fzf) throughout the workflow
- **Git workflow optimization** with custom aliases and git-spice
- **Development environment** paths and tool configurations
