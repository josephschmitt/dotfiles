# Leader Key Configuration

Configuration for [Leader Key](https://github.com/lwouis/leader-key) - a custom keyboard-driven application launcher and command palette for macOS.

## Features

- **Leader key workflow** - Press a trigger key, then follow-up keys for actions
- **Grouped commands** - Logical organization (Apps, Browsers, Editors, etc.)
- **Multiple action types** - Launch apps, open URLs, execute commands, open folders
- **Raycast integration** - Deep links to Raycast extensions and shortcuts
- **Custom shortcuts** - Personalized quick-launch combinations

## Configuration Structure

The `config.json` file defines a hierarchical menu system with groups and actions:
- **Groups** - Organize related actions (press a letter to enter)
- **Actions** - Execute when you press the final key

### Action Types

1. **Application** - Launch macOS applications
2. **URL** - Open URLs (web, Raycast extensions, shortcuts)
3. **Command** - Execute shell commands
4. **Folder** - Open directories in Finder

## Command Groups

### `a` - Apps
Quick launch for frequently used applications:
- `a` → Arc Browser
- `e` → Spark (email)
- `f` → Fantastical (calendar)
- `g` → Ghostty (terminal)
- `r` → Reeder (RSS)
- `s` → Slack

### `b` - Browsers
Switch between different browsers:
- `a` → Arc
- `b` → Brave
- `s` → Safari
- `z` → Zen

### `e` - Editors
Launch code editors:
- `b` → BBEdit
- `n` → Neovide (Neovim GUI)
- `v` → VS Code
- `z` → Zed

### `f` - Finder
Open common directories:
- `a` → Applications folder
- `d` → Development folder
- `D` → Downloads folder

### `g` - GitHub
Quick access to work repositories:
- `u` → urbancompass
- `f` → uc-frontend
- `n` → uc-node-services
- `c` → cli

### `m` - Music
Control Apple Music:
- `<` → Previous track
- `>` → Next track
- `p` → Play/Pause
- `m` → Open Music app
- `@` → Ask Music (Raycast)

### `r` - Raycast
Trigger Raycast extensions:
- `g` → GIF search
- `o` → Sesh (tmux session manager)

### `t` - Tasks
Task management shortcuts:
- `n` → New task from Arc tab (Notion)
- `t` → My tasks (Hypersonic)

### `w` - Window Management
Position windows and layouts:
- `1` → Laptop screen layout
- `2` → External monitor layout
- `h` → Left half
- `j` → Restore
- `k` → Center
- `l` → Right half

## Installation

Installed via main dotfiles setup:

```bash
stow shared
```

## Dependencies

- **Leader Key app** - The macOS application
- **Raycast** - For Raycast integration features

## Usage

1. Press the leader key (configured in the app)
2. Press a group key (shows available options)
3. Press an action key to execute

Example: Leader → `e` (Editors) → `z` (Zed) launches Zed editor.

## Customization

Edit `config.json` to add/modify actions. The structure is:
- Top-level `actions` array contains groups
- Each group has a `key`, `label`, and nested `actions`
- Each action specifies `key`, `type`, and `value` (path/URL/command)
