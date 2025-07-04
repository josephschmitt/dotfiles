# Dotfiles

Personal development environment configuration files managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Overview

This repository contains my complete development environment setup, organized for easy deployment across personal and work machines while keeping sensitive work configurations private.

## Features

- **🔧 GNU Stow-based** - Simple symlink management, no complex templating
- **🏠 Work/Personal separation** - Different configs for different contexts
- **🔒 Private work configs** - Sensitive company data kept in private submodule
- **🎨 Consistent theming** - Catppuccin theme across all tools
- **⌨️ Vi-mode everywhere** - Consistent navigation patterns
- **🔍 Fuzzy finding** - FZF integration throughout the workflow

## Quick Start

### Personal Machine
```bash
git clone git@github.com:josephschmitt/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
stow shared personal
```

### Work Machine
```bash
git clone git@github.com:josephschmitt/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
git submodule update --init --recursive
stow shared work
```

## What's Included

### Core Tools
- **Shell**: Fish with custom prompt and functions
- **Editor**: Helix with modal editing and custom keybindings
- **Terminal**: Ghostty with optimized configuration
- **Multiplexer**: tmux with plugin ecosystem
- **Version Control**: Git with comprehensive aliases

### Development Environment
- **Languages**: Node.js, Rust, Python, Go configurations
- **Package Managers**: pnpm, bun, cargo, asdf
- **Build Tools**: Nix for reproducible environments
- **CLI Tools**: FZF, EZA, Yazi, and more

### Productivity Features
- **Git workflow optimization** with git-spice integration
- **Fuzzy finding** for files, history, and processes
- **Session management** with tmux persistence
- **Custom keybindings** for efficient navigation

## Repository Structure

```
dotfiles/
├── shared/          # Common configurations for all machines
│   ├── .config/     # Application configurations
│   ├── .zshrc       # Shell configurations
│   └── README.md    # Detailed setup instructions
├── personal/        # Personal-specific configurations
│   └── .gitconfig   # Personal git settings
└── work/           # Work-specific configurations (private submodule)
    ├── .gitconfig   # Work git settings
    └── .compassrc   # Company-specific tools
```

## Documentation

For complete setup instructions, troubleshooting, and maintenance information, see:
- **[Setup Guide](shared/README.md)** - Detailed installation and configuration instructions

## Philosophy

These dotfiles follow a "files are files" philosophy - no complex templating or generation. What you see is what you get, making them easy to understand, modify, and debug.

The work/personal separation ensures you can safely share your configurations publicly while keeping sensitive company information secure in a private repository.