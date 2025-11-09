# Television Configuration

Configuration for [Television](https://github.com/alexpasmantier/television) - a blazingly fast, cross-platform general purpose fuzzy finder TUI.

## Overview

Television replaces fzf for all tmux popup interactions, providing a modern interface with excellent performance and a clean UI. Custom channels are defined as TOML files in the `cable/` directory.

## Custom Channels

### sesh

Session management channel for switching between tmux sessions, configs, and zoxide directories.

**Source**: `sesh list --icons`
**Preview**: `sesh preview {}`
**Layout**: Portrait (45% preview)

**Usage**:
```bash
# From command line
tv sesh

# From tmux
Ctrl-s o
```

### ripgrep

Interactive code search with ripgrep and bat preview.

**Source**: Dynamically generated ripgrep command (set by wrapper script)
**Preview**: Syntax-highlighted file contents with bat
**Layout**: Landscape (55% preview)

**Usage**:
```bash
# From command line (prompts for search term)
~/.config/tmux/ripgrep-popup-tv.sh

# With search term
~/.config/tmux/ripgrep-popup-tv.sh "TODO"

# From tmux
Ctrl-s g
```

**Note**: Unlike fzf's reload-on-change pattern, television loads all results upfront. The wrapper script prompts for a search term first, then runs ripgrep and pipes results to television for fuzzy filtering.

### ssh

SSH host selector with smart detection and connection info.

**Source**: `ssh-tv-list-hosts` (aggregates hosts from known_hosts, ssh config, recent connections)
**Preview**: SSH config details and connection status
**Layout**: Landscape (50% preview)

**Features**:
- Nerd font icons based on hostname patterns
- Recent connections tracking
- Connection status check (reachability test)
- SSH config preview (hostname, user, port, identity file)

**Usage**:
```bash
# From command line
tv ssh

# From tmux
Ctrl-s @
```

## Helper Scripts

### ssh-tv-list-hosts

Located in `shared/bin/ssh-tv-list-hosts`, this script aggregates SSH hosts from multiple sources:
- Recent connections (`~/.cache/tmux-ssh-recent`)
- SSH known_hosts files
- SSH config files

Outputs formatted list with icons and labels:
```
  hostname.example.com   recent
󰒋  other-host.local
```

## Installation

Television channels are automatically stowed when you install the dotfiles:

```bash
stow shared
```

This creates symlinks:
```
~/.config/television/cable/sesh.toml -> dotfiles/shared/.config/television/cable/sesh.toml
~/.config/television/cable/ripgrep.toml -> dotfiles/shared/.config/television/cable/ripgrep.toml
~/.config/television/cable/ssh.toml -> dotfiles/shared/.config/television/cable/ssh.toml
```

## Creating Custom Channels

Create new TOML files in `cable/` directory:

```toml
[metadata]
name = "mychannel"
description = "Brief description"
requirements = ["cmd1", "cmd2"]  # Optional dependencies

[source]
command = "command-to-generate-list"
display = "{}"                    # Template for display (default: whole line)
output = "{}"                     # Template for output (default: whole line)

[preview]
command = "command-to-preview {}"

[ui]
layout = "landscape"              # or "portrait"
preview_size = 50                 # percentage (1-99)
```

**Template placeholders**:
- `{}` - Full line
- `{split::N}` - Nth field (space-delimited)
- `{split:DELIM:N}` - Nth field with custom delimiter

## Dependencies

- [television](https://github.com/alexpasmantier/television) - Fuzzy finder
- [bat](https://github.com/sharkdp/bat) - Syntax highlighting (for ripgrep, ssh channels)
- [sesh](https://github.com/joshmedeski/sesh) - Session manager (for sesh channel)
- [ripgrep](https://github.com/BurntSushi/ripgrep) - Fast search (for ripgrep channel)
- `nc` (netcat) - Connection testing (for ssh channel)

## References

- [Television documentation](https://github.com/alexpasmantier/television)
- [Custom channel guide](https://github.com/alexpasmantier/television#custom-channels)
- [Tmux integration](../tmux/README.md#television-integration)
