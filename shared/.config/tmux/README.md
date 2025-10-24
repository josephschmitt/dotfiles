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
- `Ctrl-s G` - Open Lazygit in popup (90% width/height)
- `Ctrl-s N` - Open Neovim scratch buffer in popup (120 columns wide)
- `Ctrl-s C` - Open Scooter in popup (90% width/height)
- `Ctrl-s Z` - Open Yazi in popup (90% width/height)
- `Ctrl-s P` - Open floating scratch terminal (Fish shell)

### Session Management
- `Ctrl-s o` - Open Sesh session switcher
- `Ctrl-s t` - Open TWM workspace manager
- `Ctrl-s T` - Open TWM workspace manager (existing sessions only)

## Plugins

- [tpm](https://github.com/tmux-plugins/tpm) - Tmux Plugin Manager
- [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible) - Sensible default settings
- [tmux-fzf](https://github.com/sainnhe/tmux-fzf) - Fuzzy finder integration
- [tmux-fzf-url](https://github.com/wfxr/tmux-fzf-url) - URL extraction and opening
- [catppuccin-tmux](https://github.com/catppuccin/tmux) - Catppuccin Mocha theme
- [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) - Seamless vim/tmux navigation
- [tmux-tilish](https://github.com/jabirali/tmux-tilish) - i3-like window management
- [tmux-floating-terminal](https://github.com/lloydbond/tmux-floating-terminal) - Floating terminal windows
