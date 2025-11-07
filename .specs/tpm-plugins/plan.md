# TPM Plugin Refactoring Plan

## Overview

This plan outlines the refactoring of custom tmux popup implementations into reusable TPM (Tmux Plugin Manager) plugins. The goal is to create a modular, maintainable, and shareable architecture while preserving all existing functionality.

---

## Current State: Custom Popup Implementations

### Inventory of Custom Popups

| Key | Popup | Size | Feature |
|-----|-------|------|---------|
| `Ctrl-s g` | Ripgrep | large | Fast code search with live filtering |
| `Ctrl-s G` | Lazygit | medium | Git client |
| `Ctrl-s M` | Neovim Scratch | medium (120w) | Temporary notes buffer |
| `Ctrl-s C` | Scooter | medium | Application launcher |
| `Ctrl-s Z` | Yazi | large | File manager |
| `Ctrl-s o` | Sesh | small | Session switcher |
| `Ctrl-s @` | SSH | small | SSH host manager |
| `Ctrl-s t` | TWM | small | Workspace manager |
| `Ctrl-s T` | TWM (existing) | small | Workspace manager (existing sessions) |

### Infrastructure Components

**A. Standardized Popup Script** - `shared/.config/tmux/tmux-popup`
- Central launcher for all popups with consistent sizing
- Size presets: small (80%x70%), medium (90%x90%, max 250x100), large (90%x90%), full (100%x100%)
- Options: size, title, directory, width/height overrides, position control, exit-on-close
- Sets `TMUX_IN_POPUP=1` environment variable

**B. Popup-Aware Editor** - `shared/bin/popup-aware-editor`
- Opens files in existing Neovim pane instead of in popup
- Uses Neovim RPC socket detection and remote commands
- Integrates with ripgrep, Yazi, and Lazygit popups
- Smart fallback behavior

### Complex Popup Implementations

**1. Ripgrep Search** - `Ctrl-s g`
- Files: `ripgrep-popup.sh`, `rg-filter`
- Interactive file filtering with `--include` and `--exclude` patterns
- Syntax-highlighted preview with bat
- Multi-select for quickfix list, single-select to open
- Smart case sensitivity
- Adaptive layout for narrow terminals

**2. SSH Connection Manager** - `Ctrl-s @`
- Files: `ssh-popup.sh`, `ssh-connect.sh`
- Parses `~/.ssh/known_hosts` and `~/.ssh/config`
- Nerd font icons for host categorization (prod, staging, dev, cloud, etc.)
- Recent hosts tracking (`~/.cache/tmux-ssh-recent`)
- Connection status verification
- Smart tmux nesting prevention with remote session attachment

**3. Sesh Session Switcher** - `Ctrl-s o`
- File: `sesh-popup.sh`
- Multiple filter modes (all, tmux, configs, zoxide, find)
- Session kill functionality
- Rich preview pane

---

## Plugin Breakdown (4 Independent Plugins)

### 1. tmux-popup-core (Foundation Plugin)

**Purpose:** Provides the popup infrastructure that other plugins depend on

**Contents:**
- `tmux-popup` script (standardized launcher with size presets)
- `popup-aware-editor` script (Neovim RPC integration)
- Core environment variables and configuration
- Example configurations for simple popups (Lazygit, Yazi, Scooter, Neovim scratch, TWM)

**Why separate:**
- Other plugins depend on it
- Reusable by users for their own custom popups
- Provides the `TMUX_IN_POPUP` environment variable system

**Dependencies:** None

---

### 2. tmux-ripgrep-popup

**Purpose:** Advanced ripgrep search with interactive filtering

**Contents:**
- `ripgrep-popup.sh` - Main search interface
- `rg-filter` - Interactive file pattern filtering
- Syntax highlighting with bat
- Multi-select and quickfix list integration
- Smart case sensitivity

**Why separate:**
- Complex implementation (2 scripts)
- Has unique dependencies (ripgrep, fzf, bat)
- Highly customizable feature set
- Users might want just core without this

**Dependencies:** tmux-popup-core, ripgrep, fzf, bat

---

### 3. tmux-ssh-popup

**Purpose:** SSH connection manager with host discovery and status checking

**Contents:**
- `ssh-popup.sh` - Host selection UI
- `ssh-connect.sh` - Connection handler with smart nesting
- Icon mappings for host types
- Recent hosts tracking
- Connection status verification
- SSH config parsing

**Why separate:**
- Complex implementation (2 scripts)
- Specific use case (SSH users)
- Has its own cache/state (~/.cache/tmux-ssh-recent)
- Highly customizable (host icons, categories)

**Dependencies:** tmux-popup-core, ssh, fzf

---

### 4. tmux-sesh-popup

**Purpose:** Enhanced Sesh session switcher with multiple filter modes

**Contents:**
- `sesh-popup.sh` - Session manager UI
- Multiple filter modes (all, tmux, configs, zoxide, find)
- Session kill functionality
- Preview pane integration

**Why separate:**
- Depends on external tool (Sesh)
- Specific use case (session management)
- Users might use other session managers

**Dependencies:** tmux-popup-core, sesh

---

## Architecture

### Directory Structure (Each Plugin)

```
tmux-{plugin-name}/
├── README.md                    # Documentation + screenshots
├── {plugin-name}.tmux          # TPM entry point script
├── scripts/
│   ├── main-feature.sh         # Core functionality
│   └── helper-script.sh        # Supporting scripts (if any)
└── examples/
    └── custom-config.tmux      # Example user configurations
```

### TPM Entry Point Pattern

Each plugin's `.tmux` file follows this pattern:

```bash
#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Get configuration with defaults
get_tmux_option() {
    local option=$1
    local default=$2
    local value=$(tmux show-option -gqv "$option")
    echo "${value:-$default}"
}

# Validate dependency
if ! command -v tmux-popup &> /dev/null; then
    tmux display-message "tmux-{plugin-name} requires tmux-popup-core plugin"
    exit 1
fi

# Get user configuration
KEY=$(get_tmux_option "@{plugin}-popup-key" "default-key")
SIZE=$(get_tmux_option "@{plugin}-popup-size" "default-size")

# Add scripts to PATH
export PATH="$CURRENT_DIR/scripts:$PATH"

# Bind the popup
tmux bind-key -N "Feature Name" "$KEY" run-shell \
    "tmux-popup -s \"$SIZE\" -t 'Title' -E \"$CURRENT_DIR/scripts/main-feature.sh\""
```

---

## Installation & Configuration

### Installation in tmux.conf

```tmux
# Core infrastructure (required first)
set -g @plugin 'josephschmitt/tmux-popup-core'

# Feature plugins (optional, pick what you want)
set -g @plugin 'josephschmitt/tmux-ripgrep-popup'
set -g @plugin 'josephschmitt/tmux-ssh-popup'
set -g @plugin 'josephschmitt/tmux-sesh-popup'

# Initialize TPM
run '~/.tmux/plugins/tpm/tpm'
```

### Configuration Options

#### tmux-popup-core

**Default keybindings:** None (users bind manually)

**Configuration options:**
```tmux
# Size preset customization
set -g @popup-size-small-width '80%'
set -g @popup-size-small-height '70%'
set -g @popup-size-medium-width '90%'
set -g @popup-size-medium-height '90%'
set -g @popup-size-medium-max-width '250'
set -g @popup-size-medium-max-height '100'
set -g @popup-size-large-width '90%'
set -g @popup-size-large-height '90%'

# Popup-aware-editor customization
set -g @popup-editor-process-depth '3'        # RPC search depth
set -g @popup-editor-socket-timeout '100'     # Socket connection timeout (ms)
```

**Example usage in tmux.conf:**
```tmux
# Simple popup examples (documented in README)
bind-key -N "Lazygit" G run-shell "tmux-popup -s medium -t 'Lazygit' -E lazygit"
bind-key -N "Yazi" Z run-shell "tmux-popup -s large -t 'Yazi' -E yazi"
bind-key -N "Scratch Buffer" M run-shell "tmux-popup -s medium -w 120 -t 'Scratch' -E \"nvim -c 'enew | setlocal buftype=nofile bufhidden=wipe noswapfile | file [Scratch]'\""
```

---

#### tmux-ripgrep-popup

**Default keybinding:** `prefix g` (customizable)

**Configuration options:**
```tmux
set -g @ripgrep-popup-key 'g'                  # Keybinding (under prefix)
set -g @ripgrep-popup-size 'large'             # Size preset
set -g @ripgrep-popup-preview-window 'right'   # Preview position: right/top/bottom
set -g @ripgrep-popup-preview-size '60%'       # Preview pane size
set -g @ripgrep-popup-bat-theme 'auto'         # bat theme for syntax highlighting
set -g @ripgrep-popup-smart-case 'on'          # Smart case sensitivity (default: on)
set -g @ripgrep-popup-hidden 'off'             # Search hidden files (default: off)

# Custom bat options
set -g @ripgrep-popup-bat-opts '--style=numbers,grid'

# Custom fzf options (appended to defaults)
set -g @ripgrep-popup-fzf-opts '--border=rounded'

# Custom filter keybindings
set -g @ripgrep-popup-filter-include-key 'ctrl-i'
set -g @ripgrep-popup-filter-exclude-key 'ctrl-e'
```

---

#### tmux-ssh-popup

**Default keybinding:** `prefix @` (customizable)

**Configuration options:**
```tmux
set -g @ssh-popup-key '@'                      # Keybinding (under prefix)
set -g @ssh-popup-size 'small'                 # Size preset
set -g @ssh-popup-preview-size '50%'           # Preview pane size
set -g @ssh-popup-connection-timeout '1'       # Status check timeout (seconds)
set -g @ssh-popup-recent-cache '~/.cache/tmux-ssh-recent'  # Recent hosts file

# Icon customization (Nerd Fonts required)
set -g @ssh-popup-icon-prod ''
set -g @ssh-popup-icon-staging ''
set -g @ssh-popup-icon-dev ''
set -g @ssh-popup-icon-test ''
set -g @ssh-popup-icon-docker ''
set -g @ssh-popup-icon-cloud '☁'
set -g @ssh-popup-icon-linux ''
set -g @ssh-popup-icon-mac ''
set -g @ssh-popup-icon-web ''
set -g @ssh-popup-icon-db ''
set -g @ssh-popup-icon-git ''
set -g @ssh-popup-icon-localhost ''
set -g @ssh-popup-icon-default ''

# Host categorization patterns (regex)
set -g @ssh-popup-pattern-prod 'prod|production|prd'
set -g @ssh-popup-pattern-staging 'staging|stg|stage'
set -g @ssh-popup-pattern-dev 'dev|devel'
set -g @ssh-popup-pattern-test 'test|tst|qa'
set -g @ssh-popup-pattern-docker 'docker|container'
set -g @ssh-popup-pattern-cloud 'aws|azure|gcp|cloud'
set -g @ssh-popup-pattern-linux 'ubuntu|debian|centos|rhel'
set -g @ssh-popup-pattern-mac 'mac|darwin'
set -g @ssh-popup-pattern-web 'web|nginx|apache'
set -g @ssh-popup-pattern-db 'db|postgres|mysql|mongo'
set -g @ssh-popup-pattern-git 'git|github|gitlab'
set -g @ssh-popup-pattern-localhost 'localhost|127\.0\.0\.1'

# Smart nesting behavior
set -g @ssh-popup-tmux-attach 'on'             # Try to attach remote tmux (default: on)
set -g @ssh-popup-tmux-fallback 'on'           # Fallback to new session (default: on)
```

---

#### tmux-sesh-popup

**Default keybinding:** `prefix o` (customizable)

**Configuration options:**
```tmux
set -g @sesh-popup-key 'o'                     # Keybinding (under prefix)
set -g @sesh-popup-size 'small'                # Size preset
set -g @sesh-popup-preview-size '55%'          # Preview pane size

# Filter keybindings (defaults match current implementation)
set -g @sesh-popup-filter-all 'ctrl-a'
set -g @sesh-popup-filter-tmux 'ctrl-t'
set -g @sesh-popup-filter-config 'ctrl-g'
set -g @sesh-popup-filter-zoxide 'ctrl-x'
set -g @sesh-popup-filter-find 'ctrl-f'
set -g @sesh-popup-kill-session 'ctrl-d'

# Custom fzf options
set -g @sesh-popup-fzf-opts '--border=rounded'
```

---

## Benefits

### For Users:
1. **Modular:** Install only the popups you want
2. **Consistent:** All popups use the same infrastructure
3. **Customizable:** Every aspect configurable via tmux options
4. **Documented:** Each plugin has examples and configuration reference
5. **Low maintenance:** Updates via TPM

### For Maintainers:
1. **DRY:** Core infrastructure in one place
2. **Testable:** Each plugin can be tested independently
3. **Shareable:** Community can contribute improvements
4. **Versioned:** Proper releases via git tags
5. **Discoverable:** Searchable on GitHub as "tmux-popup-*"

---

## Migration Path

### Before (Current Dotfiles)
```tmux
source-file ~/.config/tmux/popup-bindings.tmux
bind-key -N "Ripgrep Search" g run-shell "~/.config/tmux/ripgrep-popup.sh"
bind-key -N "SSH Manager" @ run-shell "~/.config/tmux/ssh-popup.sh"
bind-key -N "Session Switcher" o run-shell "~/.config/tmux/sesh-popup.sh"
# ... all custom bindings
```

### After (TPM Plugins)
```tmux
set -g @plugin 'josephschmitt/tmux-popup-core'
set -g @plugin 'josephschmitt/tmux-ripgrep-popup'
set -g @plugin 'josephschmitt/tmux-ssh-popup'
set -g @plugin 'josephschmitt/tmux-sesh-popup'

# Customize if desired
set -g @ripgrep-popup-key 'g'
set -g @ssh-popup-key '@'
set -g @sesh-popup-key 'o'

run '~/.tmux/plugins/tpm/tpm'
```

**Zero breaking changes** - plugins replicate current behavior exactly, customization just moves from shell scripts to tmux options.

---

## Implementation Phases

### Phase 1: Foundation
- Create `tmux-popup-core` plugin
- Migrate `tmux-popup` script
- Migrate `popup-aware-editor` script
- Document simple popup examples
- Test with existing simple popups (Lazygit, Yazi, etc.)

### Phase 2: Complex Features
- Create `tmux-ripgrep-popup` plugin
- Create `tmux-ssh-popup` plugin
- Create `tmux-sesh-popup` plugin
- Test each independently

### Phase 3: Documentation & Polish
- Write comprehensive READMEs for each plugin
- Add screenshots/demos
- Create example configurations
- Write migration guide

### Phase 4: Release
- Tag versions for each plugin
- Publish to GitHub
- Update dotfiles to use TPM plugins
- Share with community

---

## Next Steps

1. **Start with tmux-popup-core** - Build the foundation plugin first
2. **Pick a feature plugin** - Implement one of the complex ones (ripgrep/ssh/sesh)
3. **Create a migration guide** - Document the refactoring process
4. **Complete implementation** - Build all plugins with full documentation
