# 🏠 Dotfiles

Personal development environment configuration files managed with [GNU Stow](https://www.gnu.org/software/stow/).

![Terminal Setup](https://joe.sh/content/16-terminal-tools/terminal2.jpeg)

> **Read the blog post**: [The Tools That Make My Terminal Work](https://joe.sh/terminal-tools) — A deep dive into how these configurations come together into a cohesive workflow.

## 📋 Overview

This repository contains my complete development environment setup, organized for easy deployment across personal and work machines while keeping sensitive work configurations private.

## Features

- **🔧 GNU Stow-based** - Simple symlink management, no complex templating
- **❄️ Nix-darwin managed** - Declarative macOS system configuration with reproducible environments
- **🏠 Work/Personal separation** - Different configs for different contexts
- **🔒 Private work configs** - Sensitive company data kept in private submodule
- **🎨 Consistent theming** - Tokyo Night and Catppuccin themes across tools
- **⌨️ Vi-mode everywhere** - Consistent navigation patterns
- **🔍 Fuzzy finding** - FZF integration throughout the workflow

## 🚀 Quick Start

### Prerequisites

1. **Install Nix with flakes support:**
```bash
sh <(curl -L https://nixos.org/nix/install)
```

2. **Install nix-darwin** (see [nix-darwin README](shared/.config/nix-darwin/README.md) for details):
```bash
sudo nix --extra-experimental-features nix-command --extra-experimental-features flakes run nix-darwin/master#darwin-rebuild -- switch --flake ~/dotfiles/shared/.config/nix-darwin
```

### 🏠 Personal Machine

```bash
git clone git@github.com:josephschmitt/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Apply nix-darwin configuration (installs packages, sets system preferences)
darwin_rebuild

# Install user-level configuration files
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

# Apply nix-darwin configuration (installs packages, sets system preferences)
# The darwin_rebuild wrapper automatically detects work machines and uses work configurations
darwin_rebuild

# Install user-level configuration files
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
  - macOS login shell compatibility
- **✏️ Editor**: Neovim (LazyVim) with Helix as secondary
- **💻 Terminal**: Ghostty with optimized configuration
- **🔀 Multiplexer**: tmux with plugin ecosystem, Zellij as alternative
- **🌳 Version Control**: Git with comprehensive aliases

### 🔧 Development Environment

- **❄️ System Management**: [nix-darwin](https://github.com/LnL7/nix-darwin) for declarative macOS configuration
- **📦 Package Management**: Nix packages + Homebrew integration
- **🌐 Languages**: Node.js, Rust, Python, Go configurations
- **🔨 Package Managers**: pnpm, bun, cargo, asdf, volta
- **⚡ CLI Tools**: FZF, EZA, Yazi, sesh, leader-key, ripgrep, fd, and more

### ⚡ Productivity Features

- **🌶️ Git workflow optimization** with git-spice and lazygit
- **🔍 Fuzzy finding** for files, history, and processes
- **💾 Session management** with sesh and tmux persistence
- **⌨️ Custom keybindings** for efficient navigation
- **🤖 AI assistance** with OpenCode integration

## 📁 Repository Structure

```
dotfiles/
├── shared/          # Common configurations for all machines
│   ├── .config/     # Application configurations
│   │   ├── nix-darwin/    # Declarative macOS system configuration
│   │   ├── fish/          # Fish shell configuration
│   │   ├── nvim/          # Neovim configuration (LazyVim)
│   │   ├── tmux/          # Tmux multiplexer
│   │   ├── ghostty/       # Ghostty terminal emulator
│   │   └── ...            # Other tool configurations
│   ├── bin/         # Utility scripts (darwin-rebuild-wrapper, etc.)
│   ├── .zshrc       # Shell configurations
│   └── README.md    # Detailed setup instructions
├── personal/        # Personal-specific configurations
│   ├── .config/nix-darwin/machines/mac-mini.nix  # Personal machine
│   └── .gitconfig   # Personal git settings
└── work/           # Work-specific configurations (private submodule)
    ├── .config/nix-darwin/machines/   # Work machine configurations
    ├── .gitconfig   # Work git settings
    └── .compassrc   # Company-specific tools
```

## 📚 Documentation

For complete setup instructions, troubleshooting, and maintenance information, see:

- **[Setup Guide](shared/README.md)** - Detailed installation and configuration instructions
- **[Nix-darwin Configuration](shared/.config/nix-darwin/README.md)** - System-level package and settings management

## ❄️ Nix-darwin: System-Level Configuration Management

A major component of this setup is **[nix-darwin](https://github.com/LnL7/nix-darwin)**, which provides declarative macOS system configuration. This means your entire system setup—packages, applications, system preferences, and more—is defined as code.

### Why nix-darwin?

**Reproducibility**: Define your entire system configuration once, apply it consistently across multiple machines. No more manually clicking through System Preferences or running installation scripts.

**Rollbacks**: Every system change creates a new "generation." If something breaks, roll back to a previous working state instantly.

**Machine-specific configurations**: Share common settings across all machines while maintaining machine-specific customizations (home server vs. work laptop).

### What It Manages

- **System packages**: CLI tools, development utilities (installed via Nix)
- **GUI applications**: Apps like Ghostty, VS Code, Arc browser (via Homebrew integration)
- **System preferences**: Dock position, Finder settings, keyboard behavior, etc.
- **Services**: Background daemons (e.g., Docker Compose on home server)
- **Fonts**: Nerd Fonts for terminal compatibility

### Quick Usage

```bash
# Apply system configuration changes
darwin_rebuild

# Update package versions
darwin_update

# Both: update packages then rebuild
darwin_update && darwin_rebuild
```

The `darwin_rebuild` alias intelligently detects whether you're on a personal or work machine and applies the appropriate configuration automatically.

### Integration with Dotfiles

- **Nix-darwin handles**: System-wide packages, GUI apps, macOS preferences
- **Stow handles**: User-level configuration files (shell configs, editor settings, etc.)

This separation means nix-darwin manages *what's installed and how the system behaves*, while your dotfiles manage *how those tools are configured*.

For detailed nix-darwin setup, machine configurations, and troubleshooting, see the **[Nix-darwin README](shared/.config/nix-darwin/README.md)**.

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
- **macOS compatibility** - Proper login shell handling
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

- **macOS compatibility** - Handle platform-specific shell behavior
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

