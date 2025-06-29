# dotfiles

Personal dotfiles configuration managed by [`stow`](https://formulae.brew.sh/formula/stow).

## Installation

```sh
$ brew install stow
$ git clone git@github.com:josephschmitt/dotfiles.git $HOME/dotfiles && cd $HOME/dotfiles
$ stow .
```

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
