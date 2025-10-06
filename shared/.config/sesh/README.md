# Sesh - Smart tmux Session Manager

Configuration for [sesh](https://github.com/joshmedeski/sesh) - a smart session manager for tmux that provides fuzzy-finding and quick navigation between sessions, tmux windows, config sessions, and zoxide directories.

## Features

- **Unified session switcher** - Single interface to access all session types
- **Multiple source modes** - Switch between tmux sessions, windows, config sessions, and zoxide directories
- **FZF integration** - Fast fuzzy finding with custom keybindings
- **Icon support** - Visual indicators for different session types
- **Session preview** - Preview session contents before switching
- **Quick delete** - Remove sessions directly from the picker

## Keybindings

Accessible via tmux prefix + `o` (e.g., `Ctrl-Space o`)

### In sesh picker:
- `Ctrl-a` - Show all sessions (⚡)
- `Ctrl-t` - Show tmux windows only (🪟)
- `Ctrl-g` - Show config sessions only (⚙️)
- `Ctrl-x` - Show zoxide directories only (📁)
- `Ctrl-d` - Delete selected session
- `Enter` - Connect to selected session

## Configuration

### sesh.toml

```toml
blacklist = ["scratch"]
```

- **blacklist** - Sessions to exclude from the picker (e.g., temporary or scratch sessions)

### Integration Points

**tmux.conf integration:**
- Bound to prefix + `o` for quick access
- Uses fzf-tmux popup (80% width, 70% height)
- Provides session preview in the picker
- Custom border label and prompt styling

**Session Types:**
1. **All sessions** (default) - Tmux sessions + config sessions + zoxide directories
2. **Tmux windows** - Windows in the current tmux session
3. **Config sessions** - Pre-configured project sessions
4. **Zoxide directories** - Frequently accessed directories

## Usage

### Basic Workflow

1. Press `prefix + o` to open the sesh picker
2. Start typing to filter sessions
3. Press `Enter` to connect to a session

### Mode Switching

Toggle between different session types:
- Press `Ctrl-a` to see all available sessions
- Press `Ctrl-t` to filter to only tmux windows
- Press `Ctrl-g` to see only config sessions
- Press `Ctrl-x` to see only zoxide directories

### Session Management

- Press `Ctrl-d` to delete a session without leaving the picker
- Picker automatically refreshes after deletion

## Related Tools

- **tmux** - Terminal multiplexer that sesh manages
- **fzf** - Fuzzy finder used for the picker interface
- **zoxide** - Smart directory jumper integrated as a session source
- **TWM** - Tmux workspace manager for project-based session creation

## Installation

Sesh should be installed via your system package manager. The configuration is automatically loaded from this directory when sesh runs.

```bash
# macOS
brew install joshmedeski/sesh/sesh

# After installation, reload tmux config
tmux source-file ~/.config/tmux/tmux.conf
```
