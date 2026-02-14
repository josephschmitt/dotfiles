# Tmux Configuration

Configuration for [tmux](https://github.com/tmux/tmux) - terminal multiplexer for session management and productivity.

## Configuration Structure

The tmux configuration is split into modular `conf.d/` files, each owning a single feature. The main `tmux.conf` is a minimal orchestrator that sources the reset config, globs all `conf.d/*.conf` files in order, and runs TPM last.

```
tmux/
├── tmux.conf              # Orchestrator (~15 lines)
├── tmux.reset.conf        # Clean slate for key unbinds
├── conf.d/
│   ├── 00-terminal.conf   # Terminal type, RGB, titles, passthrough
│   ├── 10-options.conf    # Prefix, mouse, indexing, history, vi-mode
│   ├── 20-appearance.conf # Status line dimensions, pane borders
│   ├── 30-plugins.conf    # Plugin declarations + all plugin configs
│   ├── 40-layouts.conf    # Pane collapse (H/J/K/L) + smart layouts (V, S)
│   ├── 50-apps.conf       # App splits, popups, television
│   └── 60-sessions.conf   # Sesh, new session, detach, kill, SSH
└── scripts/
    ├── tmux-popup             # Standardized popup sizing script
    ├── powerkit-theme.sh      # Catppuccin Mocha theme for PowerKit
    ├── powerkit-responsive.sh # Responsive status bar breakpoints
    └── ... (other scripts)
```

Numbered prefixes ensure deterministic load order. Keybindings live alongside the feature they control (e.g., plugin reload in `30-plugins.conf`, layout keys in `40-layouts.conf`).

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

- `Ctrl-s A` - Open Claude Code with adaptive layout (like `Ctrl-s V`)
- `Ctrl-s O` - Open OpenCode in 100-column right split
- `Ctrl-s /` - Open Scooter in 100-column right split

### Application Popups

- `Ctrl-s c` - Open Quick Shell popup (xsmall: closes on exit)
- `Ctrl-s C` - Open Mini Shell popup (xsmall: persistent, stays open)
- `Ctrl-s G` - Open Lazygit in popup (medium: 90% width/height, max 250 cols/100 lines)
- `Ctrl-s M` - Open Neovim scratch buffer in popup (custom: 120 columns wide)
- `Ctrl-s Z` - Open Yazi in popup (medium: 90% width/height, max 250 cols/100 lines)
- `Ctrl-s P` - Open floating scratch terminal (Fish shell)

### Television Popups

[Television](https://github.com/alexpasmantier/television) is a blazing fast fuzzy finder TUI.

- `Ctrl-s d` - Browse directories with `tv dirs` (large: 90% width/height)
- `Ctrl-s f` - Browse files with `tv files` (large: 90% width/height)
- `Ctrl-s g` - Search text with `tv text` (large: 90% width/height)

### Session Management

- `Ctrl-s o` - Open Sesh session switcher (small: 80% width, 70% height)
- `Ctrl-s w` - Detach from current session (returns to shell prompt)
- `Ctrl-s q` - Kill session and close terminal tab
- `Ctrl-s N` - Create new session with random name
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

You can create custom popup keybindings using the `~/.config/tmux/scripts/tmux-popup` script:

```tmux
# Example: Add a popup for htop
bind-key H run-shell "~/.config/tmux/scripts/tmux-popup -s medium -t 'System Monitor' -E htop"

# Example: Add a popup with custom dimensions
bind-key F run-shell "~/.config/tmux/scripts/tmux-popup -w 150 -h 40 -t 'Find Files' -E 'fd . | fzf'"
```

## Responsive Status Bar

The status bar progressively hides plugins as the terminal narrows, preventing truncation and overlap. Powered by the `powerkit-responsive.sh` script, which runs automatically on terminal resize via tmux hooks.

### Breakpoints

| Width | Plugins Shown |
|-------|--------------|
| >= 160 | session + hostname + directory + git + datetime |
| 120-159 | session + hostname + directory + git |
| 100-119 | session + directory + git |
| 80-99 | session + directory |
| < 80 | session only |

### Customizing Breakpoints

Override any breakpoint in `tmux.conf`:

```tmux
set -g @powerkit_bp_full "160"
set -g @powerkit_bp_no_datetime "120"
set -g @powerkit_bp_no_hostname "100"
set -g @powerkit_bp_no_git "80"
```

Changes take effect within ~5 seconds of resize (next status interval) or immediately on session switch.

## Plugins

- [tpm](https://github.com/tmux-plugins/tpm) - Tmux Plugin Manager
- [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible) - Sensible default settings
- [tmux-fzf](https://github.com/sainnhe/tmux-fzf) - Fuzzy finder integration
- [tmux-fzf-url](https://github.com/wfxr/tmux-fzf-url) - URL extraction and opening
- [tmux-powerkit](https://github.com/fabioluciano/tmux-powerkit) - Status bar framework (Catppuccin Mocha theme)
- [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) - Seamless vim/tmux navigation
- [tmux-tilish](https://github.com/jabirali/tmux-tilish) - i3-like window management
- [tmux-floating-terminal](https://github.com/lloydbond/tmux-floating-terminal) - Floating terminal windows

## Ripgrep Search

The Ripgrep search popup (`Ctrl-s g`) provides fast, interactive code search across your current directory. Based on [junegunn's ripgrep integration guide](https://junegunn.github.io/fzf/tips/ripgrep-integration/).

### Features

- **Fast search** - Uses [ripgrep](https://github.com/BurntSushi/ripgrep) for blazing-fast code search with live reload
- **Interactive preview** - Syntax-highlighted preview with [bat](https://github.com/sharkdp/bat), automatically centered on matched line
- **Interactive filtering** - Filter by file type or path on-the-fly with `--include`/`--exclude` flags
- **Multi-select** - Select multiple matches with `Tab/Shift-Tab` to open in quickfix list
- **Smart case** - Case-insensitive by default, case-sensitive when query contains uppercase
- **Respects .gitignore** - Automatically excludes files listed in `.gitignore`
- **Adaptive layout** - Preview window moves above search on narrow terminals (< 80 cols)

### Usage

1. Press `Ctrl-s g` to open the search popup
2. Type your search query - results update live as you type
3. Optionally use `--include` or `--exclude` to filter files (see examples below)
4. Navigate with arrow keys
5. **Single file**: Press `Enter` to open file at line number and exit, or `Ctrl-o` to open and return to search
6. **Multiple files**: Use `Tab/Shift-Tab` to select multiple matches, then `Enter` to open all in quickfix list
7. Press `Esc` to cancel

#### Filtering Examples

You can dynamically filter which files to search using `--include` and `--exclude` flags:

```
# Search only in YAML files
--include=*.yaml config

# Search only in YAML and YML files (comma-separated)
--include=*.yaml,*.yml authentication

# Search in shell scripts
--include=*.fish,*.sh,*.bash export

# Exclude test files
--exclude=*.test.js,*.spec.js function

# Exclude directories
--exclude=node_modules TODO

# Combine filters
--include=*.rs --exclude=*.test.rs struct

# Both space and equals syntax work
--include *.toml lazy
--include=*.toml lazy
```

### Keybindings (within search popup)

- `Enter` - Open file at matched line and exit
- `Ctrl-o` - Open file and return to search
- `Tab/Shift-Tab` - Select/deselect multiple matches
- `Alt-a` - Select all matches
- `Alt-d` - Deselect all matches  
- `Ctrl-/` - Toggle preview window
- `Esc` - Cancel and close popup

The preview window shows the file header (name/size) with syntax highlighting and centers on the matched line for context.

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
