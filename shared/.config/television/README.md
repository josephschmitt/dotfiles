# Television Configuration

Configuration for [Television](https://github.com/alexpasmantier/television) - a fast and hackable fuzzy finder for the terminal.

## Overview

Television is configured via TOML files and provides a channel-based interface for searching through various types of data. This configuration integrates television with tmux popups to replace fzf-based workflows.

## Directory Structure

```
.config/television/
├── config.toml          # Main television configuration
├── cable/               # Channel definitions (search recipes)
│   ├── sesh.toml       # Custom: Session management with sesh
│   ├── text.toml       # Community: Code/text search with ripgrep
│   ├── files.toml      # Community: File finder
│   ├── git-*.toml      # Community: Git operations
│   └── ...             # Other community channels
└── README.md
```

## Custom Channels

### `sesh` - Session Manager

Multi-mode session manager for tmux with cycling sources:

**Features:**
- Cycle through sources with `Ctrl+S`:
  - All sessions (tmux + zoxide + configs)
  - Tmux sessions only
  - Config directories
  - Zoxide directories  
  - Find directories
- Session preview with `sesh preview`
- Kill sessions with custom action (if bound)

**Usage:**
```bash
tv sesh
```

**Tmux Integration:**
- `Prefix` + `Ctrl+o` - Open sesh in television popup

## Community Channels

The following community-maintained channels are available after running `tv update-channels`:

### Code & Text
- `text` - Search through code with ripgrep (replacement for ripgrep-popup.sh)
- `files` - Find files and directories

### Git
- `git-branch` - Switch/manage git branches
- `git-diff` - View and stage git changes
- `git-log` - Browse git commit history
- `git-repos` - Navigate between git repositories

### System
- `env` - Browse environment variables
- `alias` - Browse shell aliases
- `procs` - Browse running processes
- `dirs` - Browse directories

### Shell History
- `fish-history` - Fish shell history
- `zsh-history` - Zsh shell history
- `bash-history` - Bash shell history

## Tmux Integration

Television is integrated with tmux via popup keybindings:

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Prefix` + `Ctrl+g` | `tv text` | Search code with ripgrep |
| `Prefix` + `Ctrl+o` | `tv sesh` | Session management (television) |
| `Prefix` + `o` | `sesh` + fzf | Session management (fzf - legacy) |
| `Prefix` + `g` | ripgrep + fzf | Code search (fzf - legacy) |

**Scripts:**
- `tv-popup` - Wrapper script for launching tv in tmux popups

## Extensibility

### Creating Custom Channels

Create a new channel in `~/.config/television/cable/`:

```toml
[metadata]
name = "my-channel"
description = "Description of what this searches"
requirements = ["required", "binaries"]

[source]
command = "command-that-generates-entries"
ansi = true  # if command outputs ANSI colors

[preview]
command = "command-to-preview {}"  # {} replaced with selected entry
env = { ENV_VAR = "value" }

[ui]
layout = "landscape"

[ui.preview_panel]
size = 50  # percentage of screen

[keybindings]
shortcut = "f5"  # Quick switch key

[actions.my_action]
description = "Do something with selection"
command = "my-command {}"
mode = "execute"  # or "fork"
```

### Using Custom Channels in Tmux

Add to `tmux.conf`:

```tmux
bind-key <key> run-shell "#{d:config_files}/tmux-popup -s large -t 'My Channel' -E tv my-channel || true"
```

## Configuration

Main configuration is in `config.toml`:

**Key Settings:**
- `default_channel` - Channel to use with bare `tv` command
- `tick_rate` - UI update frequency (default: 50)
- `ui.orientation` - Layout: "landscape" or "portrait"
- `ui.theme` - Color theme (default: "default")
- `ui.preview_panel.size` - Preview panel size (default: 50%)

**Shell Integration:**
- `Ctrl+T` - Smart autocomplete (context-aware channel selection)
- `Ctrl+R` - Command history search

## Resources

- [Television GitHub](https://github.com/alexpasmantier/television)
- [Documentation](https://alexpasmantier.github.io/television/)
- [Community Channels](https://alexpasmantier.github.io/television/docs/Users/community-channels-unix)
- [Channel Specification](https://alexpasmantier.github.io/television/docs/Users/channels)

## Updating Channels

Update community-maintained channels:

```bash
tv update-channels
```

This downloads the latest channel prototypes from the television repository.
