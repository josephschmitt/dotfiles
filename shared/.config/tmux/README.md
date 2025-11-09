# Tmux Configuration

Configuration for [tmux](https://github.com/tmux/tmux) - terminal multiplexer for session management and productivity.

## Installation

### 1. Ensure proper Stow setup

Before installing tmux plugins, make sure the `~/.config/tmux` directory exists so Stow doesn't symlink the entire directory:

```bash
mkdir -p ~/.config/tmux
```

**Why this matters:**

- Stow symlinks entire directories if they don't exist at the target location
- If Stow symlinks the entire `~/.config/tmux/` directory, the `plugins/` subdirectory will also be symlinked
- TPM needs to create and manage `~/.config/tmux/plugins/` as a real directory, not a symlink
- Creating `~/.config/tmux` first forces Stow to symlink individual files (like `tmux.conf`) instead

### 2. Install TPM (Tmux Plugin Manager)

```bash
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
```

### 3. Install plugins

Inside tmux, press: `Ctrl-s I` (prefix + I)

## Custom Layouts

### Vertical Split Layout (`Ctrl-s V`)

Adaptive vertical split layout that adjusts based on terminal width:

**< 210 columns** - 50/50 split:

```
┌─────────────────────────┬─────────────────────────┐
│                         │                         │
│       Pane 1            │       Pane 2            │
│      ~85 cols           │      ~85 cols           │
│       (50%)             │       (50%)             │
│                         ├─────────────────────────┤
│                         │       Pane 3            │
│                         │      15 rows            │
└─────────────────────────┴─────────────────────────┘
```

**≥ 210 and < 310 columns** - Fixed 100 col right pane:

```
┌──────────────────────────────┬─────────────────┐
│                              │                 │
│         Pane 1               │    Pane 2       │
│       ~150 cols              │   100 cols      │
│                              ├─────────────────┤
│                              │    Pane 3       │
│                              │   15 rows       │
└──────────────────────────────┴─────────────────┘
```

**≥ 310 columns** - 33% right pane:

```
┌──────────────────────────────────┬─────────────────────┐
│                                  │                     │
│           Pane 1                 │      Pane 2         │
│         ~240 cols                │    ~120 cols        │
│          (67%)                   │      (33%)          │
│                                  ├─────────────────────┤
│                                  │      Pane 3         │
│                                  │     15 rows         │
└──────────────────────────────────┴─────────────────────┘
```

### Horizontal Split Layout (`Ctrl-s S`)

Main-horizontal layout with fixed 20-row bottom panes:

```
┌──────────────────────────────────────────────────────┐
│                                                      │
│                                                      │
│                                                      │
│                    Pane 1                            │
│                  (main pane)                         │
│                                                      │
│                                                      │
│                                                      │
├────────────────────────────┬─────────────────────────┤
│          Pane 2            │         Pane 3          │
│         20 rows            │        20 rows          │
└────────────────────────────┴─────────────────────────┘
```

## Key Bindings

### Prefix Key

- `Ctrl-s` - Primary prefix (instead of default `Ctrl-b`)

### Pane Collapse (Resize to Minimum)

- `Ctrl-s H` - Collapse pane left
- `Ctrl-s J` - Collapse pane down
- `Ctrl-s K` - Collapse pane up
- `Ctrl-s L` - Collapse pane right

### Application Splits

- `Ctrl-s O` - Open OpenCode in 100-column right split
- `Ctrl-s /` - Open Scooter in 100-column right split

### Application Popups

- `Ctrl-s g` - Open Ripgrep search in popup (large: 90% width/height)
- `Ctrl-s G` - Open Lazygit in popup (large: 90% width/height)
- `Ctrl-s N` - Open Neovim scratch buffer in popup (custom: 120 columns wide)
- `Ctrl-s C` - Open Scooter in popup (large: 90% width/height)
- `Ctrl-s Z` - Open Yazi in popup (large: 90% width/height)
- `Ctrl-s P` - Open floating scratch terminal (Fish shell)

### Session Management

- `Ctrl-s o` - Open Sesh session switcher (small: 80% width, 70% height)
- `Ctrl-s @` - Open SSH host selector with smart tmux handling (small: 80% width, 70% height)
- `Ctrl-s t` - Open TWM workspace manager (small: 80% width, 70% height)
- `Ctrl-s T` - Open TWM workspace manager for existing sessions (small: 80% width, 70% height)

## Popup Management

### Standardized Popup Script

All tmux popups use the `tmux-popup` script for consistent behavior and sizing. The script provides standardized size presets:

| Preset     | Dimensions                                           | Use Case                             |
| ---------- | ---------------------------------------------------- | ------------------------------------ |
| **small**  | 80% width, 70% height                                | FZF menus, session switchers         |
| **medium** | 90% width (max 250 cols), 90% height (max 100 lines) | General purpose editing              |
| **large**  | 90% width, 90% height                                | Full applications like Lazygit, Yazi |
| **full**   | 100% width, 100% height                              | Maximum space utilization            |

The medium preset intelligently limits to 250 columns and 100 lines maximum to prevent overly large popups on ultrawide monitors.

### Popup-Aware Editor

When opening files from within a popup (e.g., selecting a file in Ripgrep or Yazi), the editor automatically opens in an **existing Neovim pane** rather than inside the popup. This provides a seamless IDE-like workflow where:

1. Open a popup (Ripgrep, Yazi, etc.) with a tmux keybinding
2. Browse/search for files in the popup
3. Select a file to edit
4. The file opens in your Neovim pane using RPC
5. The popup automatically closes

This is achieved through:
- The `popup-aware-editor` wrapper script in `~/bin/`
- Neovim RPC server enabled via `serverstart()` in your config
- Detecting running Neovim instances with listen sockets
- Using `nvim --remote` to open files via RPC

**Behavior:**
- If a Neovim instance with RPC is found in the current window: opens the file there
- If no Neovim instance found: opens the editor in the popup itself

**Supported in:**
- Ripgrep search popup (`Ctrl-s g`)
- Yazi file manager popup (`Ctrl-s Z`)
- Lazygit popup (`Ctrl-s G`) - when pressing `e` to edit files
- Any custom popup that calls `popup-aware-editor`

**Requirements:**
- Neovim must be running with RPC enabled (automatically configured in `lua/config/options.lua`)
- `lsof` command must be available (for detecting Neovim sockets)

### Custom Popup Usage

You can create custom popup keybindings using the `~/.config/tmux/tmux-popup` script:

```tmux
# Example: Add a popup for htop
bind-key H run-shell "~/.config/tmux/tmux-popup -s medium -t 'System Monitor' -E htop"

# Example: Add a popup with television for file finding
bind-key F run-shell "~/.config/tmux/tmux-popup -w 150 -h 40 -t 'Find Files' -E 'tv files'"
```

## Television Integration

All fuzzy-finding popups use [television](https://github.com/alexpasmantier/television), a modern, cross-platform fuzzy finder with excellent performance and a clean UI.

### Custom Channels

Television channels are defined in `~/.config/television/cable/` as TOML files. This configuration includes three custom channels:

**sesh.toml** - Session management
```toml
[source]
command = "sesh list --icons"

[preview]
command = "sesh preview {}"
```

**ripgrep.toml** - Code search (see detailed section above)

**ssh.toml** - SSH host selection
```toml
[source]
command = "ssh-tv-list-hosts"

[preview]
# Shows SSH config and connection status
```

### Creating Custom Channels

You can create your own television channels for any list-based workflow:

```bash
# 1. Create a channel file
nvim ~/.config/television/cable/mychannel.toml

# 2. Define the channel
[metadata]
name = "mychannel"
description = "Description of your channel"

[source]
command = "command-that-generates-list"

[preview]
command = "command-to-preview {}"

# 3. Use it from tmux
bind-key X run-shell "tmux-popup -s medium -t 'My Channel' -E 'tv mychannel'"
```

See the [television documentation](https://github.com/alexpasmantier/television) for more advanced channel features like custom output templates, UI layouts, and keybindings.

## Dependencies

### Required Tools

- [television](https://github.com/alexpasmantier/television) - Modern fuzzy finder powering all popup selectors
- [bat](https://github.com/sharkdp/bat) - Syntax-highlighted file previews
- [ripgrep](https://github.com/BurntSushi/ripgrep) - Fast code search
- [sesh](https://github.com/joshmedeski/sesh) - Session manager

### Optional Tools

- [fd](https://github.com/sharkdp/fd) - Fast file finder
- [lazygit](https://github.com/jesseduffield/lazygit) - Terminal git UI
- [yazi](https://github.com/sxyazi/yazi) - Terminal file manager

## Plugins

- [tpm](https://github.com/tmux-plugins/tpm) - Tmux Plugin Manager
- [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible) - Sensible default settings
- [tmux-fzf](https://github.com/sainnhe/tmux-fzf) - Fuzzy finder integration (legacy)
- [tmux-fzf-url](https://github.com/wfxr/tmux-fzf-url) - URL extraction and opening
- [catppuccin-tmux](https://github.com/catppuccin/tmux) - Catppuccin Mocha theme
- [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) - Seamless vim/tmux navigation
- [tmux-tilish](https://github.com/jabirali/tmux-tilish) - i3-like window management
- [tmux-floating-terminal](https://github.com/lloydbond/tmux-floating-terminal) - Floating terminal windows

## Ripgrep Search

The Ripgrep search popup (`Ctrl-s g`) provides fast, interactive code search across your current directory using [television](https://github.com/alexpasmantier/television).

### Features

- **Fast search** - Uses [ripgrep](https://github.com/BurntSushi/ripgrep) for blazing-fast code search
- **Interactive preview** - Syntax-highlighted preview with [bat](https://github.com/sharkdp/bat), automatically centered on matched line
- **Fuzzy filtering** - Filter search results with fuzzy matching via television
- **Smart case** - Case-insensitive by default, case-sensitive when query contains uppercase
- **Hidden files** - Searches hidden files (respects `.git` exclusion)
- **Modern UI** - Clean, responsive interface powered by television

### Usage

1. Press `Ctrl-s g` to open the search popup
2. Enter your search query at the prompt
3. Results appear instantly - use television's fuzzy search to filter them further
4. Navigate with arrow keys or `j/k`
5. Press `Enter` to select and output the file:line location
6. Press `Esc` or `q` to cancel

### Example Workflow

```bash
# Press Ctrl-s g
🔍 Search query: TODO

# Television shows all lines containing "TODO"
# Type additional characters to fuzzy filter results
# Preview pane shows the matched line with context
# Press Enter to select
```

### Television Channels

The ripgrep functionality is powered by a custom television channel defined in `~/.config/television/cable/ripgrep.toml`. You can also invoke it directly:

```bash
# Search from command line
tv ripgrep --input "search term"

# Or use the wrapper script
~/.config/tmux/ripgrep-popup-tv.sh "search term"
```

## SSH Session Manager

The SSH popup (`Ctrl-s @`) provides an enhanced SSH connection experience with:

### Features

- **Smart host detection** - Parses `~/.ssh/known_hosts` for SSH connection history, plus `~/.ssh/config` for configured hosts
- **Nerd font icons** - Visual host categorization:
  -  Production servers (`*prod*`, `*production*`)
  -  Staging servers (`*stage*`, `*staging*`)
  - 󰵮 Development servers (`*dev*`, `*develop*`)
  - 󰙨 Test servers (`*test*`)
  -  Docker/Container hosts (`*docker*`, `*container*`)
  - 󰅟 Cloud instances (`*aws*`, `*ec2*`, `*cloud*`)
  -  Linux servers (`*ubuntu*`, `*debian*`, `*linux*`)
  -  macOS servers (`*mac*`, `*darwin*`)
  - 󰖟 Web servers (`*web*`, `*www*`)
  -  Database servers (`*db*`, `*database*`)
  -  Git servers (`*git*`)
  -  Localhost (`localhost`, `127.*`)
  - 󰒋 Default server icon
- **Recent hosts tracking** - Shows recent connections at the top
- **Connection status preview** - Tests if hosts are reachable (1-second timeout)
- **SSH config preview** - Shows hostname, user, port, and identity file
- **Smart tmux handling** - Avoids tmux-in-tmux nesting:
  - Connects in new tmux window (not nested session)
  - Attempts to attach to existing remote tmux session
  - Falls back to creating new remote tmux session
  - Falls back to shell if tmux unavailable on remote

### Keybindings (within SSH popup)

- `↑/↓` or `Tab/Shift-Tab` - Navigate hosts
- `Ctrl-r` - Reload host list
- `Enter` - Connect to selected host
- `Esc` - Cancel

### Recent Hosts

Recent SSH connections are tracked in `~/.cache/tmux-ssh-recent` and displayed with a indicator at the top of the list for quick access to frequently used hosts.
