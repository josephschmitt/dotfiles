# Nix Darwin Configuration

Declarative macOS system configuration using [nix-darwin](https://github.com/LnL7/nix-darwin) with machine-specific setups and Homebrew integration.

## Overview

This configuration manages macOS systems declaratively using Nix, providing:
- **Reproducible environments** across multiple machines
- **Package management** via Nix and Homebrew
- **System preferences** and defaults configuration
- **Machine-specific configurations** for different hardware setups
- **Font management** with Nerd Fonts

## Structure

```
.config/nix-darwin/
├── flake.nix           # Main flake with machine configurations
├── darwin.nix         # Shared system configuration
├── machines/           # Machine-specific configurations
│   ├── mac-mini.nix    # Personal Mac mini server
│   └── [work machines] # Work MacBook Pro configurations
├── flake.lock          # Dependency lockfile
└── README.md           # This file
```

## Managed Systems

### Personal Mac Mini (`mac-mini`)
- **Purpose**: Home server and development machine
- **Additional packages**: Docker, file managers, development tools
- **Services**: Docker Compose daemon for home services
- **Dock**: Minimal setup with essential apps

### Work MacBooks
- **Purpose**: Professional development workstations
- **Focus**: Development tools and productivity applications
- **Configuration**: Optimized for software engineering workflows

## Package Management

### Nix Packages (System-wide)
- **Development**: `neovim`, `gh`, `lazygit`, `ripgrep`, `fd`
- **Shell**: `fish`, `zellij`, `tmux`, `fzf`, `zoxide`, `atuin`
- **Tools**: `stow`, `oh-my-posh`, `volta`, `asdf-vm`
- **AI**: `claude-code`, `codex`

### Homebrew Integration
- **CLI tools**: `helix`, `opencode`
- **Applications**: 1Password, Arc, ChatGPT, Claude, Ghostty, VS Code
- **Productivity**: Raycast, Hyperkey, Leader Key
- **Creative**: Adobe Creative Cloud

## System Defaults

### Dock Configuration
- **Position**: Left side (space-efficient on wide screens)
- **Process indicators**: Enabled for running applications
- **Tile size**: Optimized per machine

### Finder Settings
- **Show all extensions**: Enabled for transparency
- **Default search scope**: Current folder
- **View style**: List view for detailed information

### Input & Accessibility
- **Tap to click**: Enabled on trackpads
- **Full keyboard control**: Enabled for accessibility
- **Key repeat**: Enabled in VS Code
- **System beep**: Disabled

### File System
- **Network .DS_Store**: Disabled to prevent clutter
- **Auto-termination**: Disabled for stability

## Installation

### Initial Setup

1. **Install Nix with flakes support:**
```bash
sh <(curl -L https://nixos.org/nix/install)
```

2. **Install nix-darwin:**
```bash
sudo nix --extra-experimental-features nix-command --extra-experimental-features flakes run nix-darwin/master#darwin-rebuild -- switch --flake ~/dotfiles/shared/.config/nix-darwin
```

3. **Apply configuration using the convenience alias:**
```bash
nix_rebuild
```

Or manually:
```bash
darwin-rebuild switch --flake ~/dotfiles/shared/.config/nix-darwin
```

### Daily Usage

#### Convenience Commands

This configuration includes shell aliases for easier management:

```bash
# Apply configuration changes
nix_rebuild

# Update flake dependencies
nix_update

# Update and rebuild in one command
nix_update && nix_rebuild
```

#### What the Wrapper Does

The `nix_rebuild` alias uses a smart wrapper script (`darwin-rebuild-wrapper.sh`) that:

1. **Detects your machine** by hostname
2. **Determines if you're on a work or personal machine**
3. **Checks for work submodule availability** (for work machines)
4. **Applies the correct flake configuration automatically**:
   - Work machines: Uses impure evaluation with submodules
   - Personal machines: Uses pure evaluation

This means you never have to remember the complex `darwin-rebuild` command syntax or worry about which configuration to use.

#### Manual Commands

If you prefer to run commands manually or need more control:

```bash
# Personal machines
darwin-rebuild switch --flake ~/dotfiles/shared/.config/nix-darwin

# Work machines (requires work submodule)
darwin-rebuild switch --impure --flake "git+file://$HOME/dotfiles?dir=shared/.config/nix-darwin&submodules=1#$(hostname -s)"

# Update flake dependencies
nix flake update --flake ~/dotfiles/shared/.config/nix-darwin
```

## Machine-Specific Configuration

Each machine has its own configuration file in `machines/` that extends the base `darwin.nix`:

- **Additional packages** specific to the machine's purpose
- **Custom dock layouts** and application preferences  
- **Hardware-specific settings** (Intel vs Apple Silicon)
- **Service configurations** (like Docker on the Mac mini)

## Fonts

Managed Nerd Fonts for terminal and editor compatibility:
- **Meslo LG Nerd Font** - Primary terminal font
- **Fira Code Nerd Font** - Alternative with ligatures

## Troubleshooting

### Common Issues
- **Permission errors**: Ensure user has admin privileges
- **Homebrew conflicts**: Run `brew doctor` to check for issues
- **Nix store corruption**: Run `nix store verify --all`

### Useful Commands
```bash
# Check current generation
darwin-rebuild --list-generations

# Rollback to previous generation
sudo darwin-rebuild rollback

# Garbage collect old generations
nix-collect-garbage -d
```
