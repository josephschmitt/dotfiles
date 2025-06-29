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

**Note:** The shell configuration has been reorganized to follow Unix best practices. Your existing shell configs will be replaced with the new modular structure that eliminates duplication across Fish, Zsh, and Bash.

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

**Notes:** 
- Work setup requires access to the private `dotfiles-work-private` repository
- The shell configuration has been reorganized to follow Unix best practices with shared modules

## Structure

- `shared/` - Common configurations used on all machines
- `personal/` - Personal-specific configs (personal email, etc.)
- `work/` - Work-specific configs (private submodule with work email, company tools, etc.)

## What's Included

### Shell Configuration
Multi-shell setup following Unix best practices with shared configuration:

- **Fish Shell** (`.config/fish/`) - Primary shell with modern features
  - Self-contained configuration with Fish-specific syntax
  - Vi-mode keybindings and custom functions
  - Oh-my-posh prompt integration
  
- **Zsh** (`.zshrc`, `.zshenv`, `.zprofile`) - Alternative shell
  - Zinit plugin manager with syntax highlighting and autocompletion
  - Shared aliases and functions via POSIX-compliant modules
  - macOS Terminal.app compatibility (login shell handling)
  
- **Bash** (`.bashrc`, `.bash_profile`) - Fallback shell
  - POSIX-compliant configuration
  - Shared environment and interactive setup

**Shared Configuration Philosophy:**
- **`.profile`** - Central environment setup (PATH, exports) for all POSIX shells
- **`.config/shell/`** - Modular shared configuration:
  - `exports.sh` - Environment variables
  - `aliases.sh` - Common aliases (git-spice, development tools)
  - `functions.sh` - Shared shell functions
- **No duplication** - Environment and aliases defined once, sourced everywhere
- **Shell-specific optimizations** - Each shell can have unique features while sharing core config

**Setup Details:**
- Stow will symlink individual `.config` subdirectories (never the entire `.config` folder)
- Shell profiles (`.zshrc`, `.bashrc`, etc.) will be symlinked to your home directory
- The new `.profile` file provides centralized environment setup for all shells

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