# Dotfiles

Personal configuration files for development environment using [GNU Stow](https://www.gnu.org/software/stow/) with work/personal separation.

## Quick Start

### Prerequisites

**Required:**
- [GNU Stow](https://www.gnu.org/software/stow/) for symlink management
- Git with SSH keys configured for GitHub

**Install Stow:**
```bash
# macOS
brew install stow

# Ubuntu/Debian
sudo apt install stow

# Arch Linux
sudo pacman -S stow
```

### Installation

#### Personal Machine Setup
```bash
# 1. Clone the repository
git clone git@github.com:josephschmitt/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# 2. Update personal email in personal/.gitconfig
# Edit personal/.gitconfig and replace "your-personal@email.com" with your actual email

# 3. Apply configurations
stow shared personal

# 4. Restart your shell or source configs
exec $SHELL
```

#### Work Machine Setup
```bash
# 1. Clone the repository
git clone git@github.com:josephschmitt/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# 2. Initialize work submodule (requires access to private work repo)
git submodule update --init --recursive

# 3. Apply configurations
stow shared work

# 4. Restart your shell or source configs
exec $SHELL
```

**Note:** Work setup requires access to the private `dotfiles-work-private` repository.

## Structure

- `shared/` - Common configurations used on all machines
- `personal/` - Personal-specific configs (personal email, etc.)
- `work/` - Work-specific configs (private submodule with work email, company tools, etc.)

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

## Troubleshooting

### Stow Conflicts
If stow reports conflicts with existing files:
```bash
# Backup existing configs
mkdir ~/dotfiles-backup
mv ~/.gitconfig ~/dotfiles-backup/  # repeat for conflicting files

# Then retry stow
stow shared personal  # or work
```

### Missing Submodule (Work Setup)
If work directory is empty:
```bash
git submodule update --init --recursive --force
```

### Permission Issues
Ensure your SSH key has access to the repositories:
```bash
ssh -T git@github.com
```

## Updating

### Pull Latest Changes
```bash
cd ~/.dotfiles
git pull origin main

# For work machines, also update submodule
git submodule update --remote
```

### Adding New Configs
1. Add files to appropriate directory (`shared/`, `personal/`, or `work/`)
2. Re-run stow: `stow shared personal` (or `work`)

## Uninstalling

To remove all symlinks:
```bash
cd ~/.dotfiles
stow -D shared personal  # or work
```