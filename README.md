# 🏠 Dotfiles

Personal development environment configuration files managed with [GNU Stow](https://www.gnu.org/software/stow/).

## 📋 Overview

This repository contains my complete development environment setup, organized for easy deployment across personal and work machines while keeping sensitive work configurations private.

## Features

- **🔧 GNU Stow-based** - Simple symlink management, no complex templating
- **🏠 Work/Personal separation** - Different configs for different contexts
- **🔒 Private work configs** - Sensitive company data kept in private submodule
- **🎨 Consistent theming** - Catppuccin theme across all tools
- **⌨️ Vi-mode everywhere** - Consistent navigation patterns
- **🔍 Fuzzy finding** - FZF integration throughout the workflow

## 🚀 Quick Start

### 🏠 Personal Machine

```bash
git clone git@github.com:josephschmitt/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
# Ensure Stow symlinks individual .config subdirectories, not the entire .config folder
# (Stow symlinks entire directories unless they already exist at the target)
mkdir -p ~/.config/tmux
stow shared personal
```

### 💼 Work Machine

```bash
git clone git@github.com:josephschmitt/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
git submodule update --init --recursive
# Ensure Stow symlinks individual .config subdirectories, not the entire .config folder
# (Stow symlinks entire directories unless they already exist at the target)
mkdir -p ~/.config/tmux
stow shared work
```

#### Removing Work Submodule

When you're done working with the work submodule and want to remove it from your machine:

```bash
git submodule deinit -f work
```

This clears the `work/` directory and unregisters the submodule without affecting the main repository.

## 📦 What's Included

### 🛠️ Core Tools

- **🐚 Multi-Shell Setup**: Fish (primary), Zsh (secondary), Bash (fallback)
  - Shared configuration modules to eliminate duplication
  - POSIX-compliant environment setup across all shells
  - macOS Terminal.app compatibility with proper login shell handling
- **✏️ Editor**: Neovim (LazyVim) with Helix as secondary
- **💻 Terminal**: Ghostty with optimized configuration
- **🔀 Multiplexer**: tmux with plugin ecosystem
- **🌳 Version Control**: Git with comprehensive aliases

### 🔧 Development Environment

- **🌐 Languages**: Node.js, Rust, Python, Go configurations
- **📦 Package Managers**: pnpm, bun, cargo, asdf
- **🏗️ Build Tools**: Nix for reproducible environments
- **⚡ CLI Tools**: FZF, EZA, Yazi, and more

### ⚡ Productivity Features

- **🌶️ Git workflow optimization** with git-spice integration
- **🔍 Fuzzy finding** for files, history, and processes
- **💾 Session management** with tmux persistence
- **⌨️ Custom keybindings** for efficient navigation

## 📁 Repository Structure

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

## 📚 Documentation

For complete setup instructions, troubleshooting, and maintenance information, see:

- **[Setup Guide](shared/README.md)** - Detailed installation and configuration instructions

## 🎯 Core Philosophy

This dotfiles repository is built around several key principles that prioritize maintainability, Unix best practices, and real-world usability.

### 1. 🎯 Simplicity Over Complexity

**"Files are files"** - No complex templating, generation, or build systems. What you see in the repository is exactly what gets deployed. This makes the configuration:

- **Debuggable**: Easy to trace issues to specific files
- **Portable**: Works anywhere without special tooling
- **Understandable**: New contributors can immediately see what's happening
- **Reliable**: No hidden dependencies or generation failures

### 2. 🐧 Unix Best Practices with Modern Realities

The shell configuration follows traditional Unix conventions while acknowledging modern multi-shell workflows:

**Traditional Unix Approach:**

- **`.profile`** - POSIX-compliant environment setup (PATH, exports)
- **Shell-specific rc files** - Interactive configuration only
- **Proper sourcing hierarchy** - Login vs non-login shell handling

**Modern Adaptations:**

- **Shared modules** (`.config/shell/`) - Eliminate duplication across shells
- **macOS compatibility** - Handle Terminal.app's login shell quirks
- **Multi-shell support** - Fish, Zsh, and Bash coexist harmoniously

**Why This Matters:**

- **No duplication**: Environment variables and aliases defined once
- **Consistency**: Same behavior across all shells
- **Flexibility**: Each shell can leverage its unique features
- **Maintainability**: Changes propagate automatically

### 3. 🔒 Security Through Separation

**Work/Personal Isolation:**

- **Public sharing safe** - Personal configs can be shared openly
- **Private submodule** - Work-specific configs stay in company-controlled repository
- **Context switching** - Different git identities and tool configurations per environment
- **Compliance friendly** - Meets corporate security requirements

### 4. 🛠️ Practical Over Perfect

**Real-world considerations:**

- **macOS Terminal.app quirks** - Handled explicitly rather than ignored
- **Multiple package managers** - Support for the tools actually used (npm, pnpm, bun, cargo, etc.)
- **Fallback compatibility** - Bash support for systems where Fish/Zsh aren't available
- **Tool integration** - Configurations work together (tmux + vim navigation, fzf everywhere)

### 5. 📖 Documentation as Code

**Self-documenting approach:**

- **Clear file organization** - Purpose obvious from structure
- **Comprehensive READMEs** - Both for humans and AI assistants
- **Inline comments** - Explain non-obvious decisions
- **Philosophy preservation** - Guidelines prevent architectural drift

This philosophy ensures the dotfiles remain maintainable and useful as tools, workflows, and requirements evolve over time.

