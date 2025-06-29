# Neovim Configuration

Personal Neovim configuration built on [LazyVim](https://github.com/LazyVim/LazyVim) with AI-powered development tools and workflow optimizations.

## Overview

This configuration extends LazyVim with custom plugins and settings focused on:
- **AI-powered coding** with multiple AI assistants (Avante, CodeCompanion, Copilot)
- **Terminal integration** with tmux and zellij navigation
- **File management** with yazi integration
- **Modern development** with LSP, treesitter, and fuzzy finding

## Structure

```
.config/nvim/
├── init.lua              # Entry point - bootstraps lazy.nvim
├── lua/
│   ├── config/           # Core configuration
│   │   ├── autocmds.lua  # Auto commands
│   │   ├── keymaps.lua   # Key mappings
│   │   ├── lazy.lua      # Plugin manager setup
│   │   └── options.lua   # Vim options
│   └── plugins/          # Plugin configurations
│       ├── avante.lua    # AI coding assistant
│       ├── blink.lua     # Completion engine
│       ├── copilot*.lua  # GitHub Copilot integration
│       ├── fzf-lua.lua   # Fuzzy finder
│       ├── mcphub.lua    # MCP (Model Context Protocol) hub
│       ├── yazi.lua      # File manager integration
│       └── ...           # Other plugin configs
└── lazy-lock.json        # Plugin version lockfile
```

## Key Features

### AI Assistants
- **Avante** - Advanced AI coding assistant with MCP integration
- **CodeCompanion** - Chat-based AI assistant
- **GitHub Copilot** - Code completion and chat

### Terminal Integration
- **tmux-navigator** - Seamless navigation between vim and tmux panes
- **zellij-nav** - Navigation support for zellij terminal multiplexer

### File Management
- **yazi** - Modern file manager integration
- **fzf-lua** - Fast fuzzy finding for files, buffers, and more

### Development Tools
- **LSP** - Language server protocol support
- **Treesitter** - Advanced syntax highlighting and text objects
- **Multicursor** - Multiple cursor editing
- **Diffview** - Git diff and merge conflict resolution

## Installation

This configuration is managed as part of the dotfiles. Install via stow:

```bash
cd ~/dotfiles
stow .
```

## Customization

- **Plugin configs**: Add new plugins in `lua/plugins/`
- **Keymaps**: Modify `lua/config/keymaps.lua`
- **Options**: Adjust `lua/config/options.lua`
- **Auto commands**: Edit `lua/config/autocmds.lua`

## Dependencies

- Neovim 0.9+
- Git
- A Nerd Font for icons
- ripgrep for fuzzy finding
- fd for file finding
- Node.js for some LSP servers
