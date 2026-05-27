# Remote Sandbox tmux Config

A standalone, zero-dependency tmux configuration for [crafting.dev](https://crafting.dev) sandboxes. Polished enough to feel good out of the box, simple enough for non-tmux-experts.

## Quick Start

```bash
# Option A: Stow (on the sandbox, not your local machine)
stow remote-sandbox

# Option B: Copy the file manually
cp remote-sandbox/.tmux.conf ~/
```

Start tmux — you'll see a styled status bar with a keybinding cheat sheet on the second line.

## What's Included

- **Prefix**: `C-s` (Ctrl+s) instead of the default `C-b`
- **Mouse support**: Click panes, scroll, resize — all enabled
- **Vi copy mode**: `v` to select, `y` to yank, `J`/`K` to scroll
- **Catppuccin Mocha theme**: Dark, easy-on-the-eyes color scheme
- **Two-line status bar**: Tab bar on top, keybinding hints below
- **1-indexed windows/panes**: Matches keyboard layout (no reaching for `0`)

## Keybindings

The bottom status bar shows the most common keys. Press `C-s ?` for the full list.

### Windows

| Key | Action |
|-----|--------|
| `C-s n` | New window |
| `Alt+n` | New window (no prefix) |
| `C-s r` | Rename window |
| `C-s X` | Kill window |
| `Alt+[` / `Alt+]` | Previous / next window |

### Panes

| Key | Action |
|-----|--------|
| `C-s -` | Horizontal split |
| `C-s \|` | Vertical split |
| `C-s x` | Kill pane |
| `Alt+`` ` / `Alt+~` | Next / previous pane |
| `C-s 1-9` | Select pane by number |
| `C-s h/j/k/l` | Resize pane (repeatable) |
| `C-s *` | Synchronize panes (type in all) |

### Sessions

| Key | Action |
|-----|--------|
| `C-s s` | Rename session |
| `C-s d` | Detach |
| `C-s q` | Kill session |

### Copy Mode

| Key | Action |
|-----|--------|
| `C-s v` | Enter copy mode |
| `v` | Begin selection |
| `y` | Yank (copy) |
| `J` / `K` | Scroll down / up |
| `/` | Search |
| `Esc` | Exit copy mode |

### Other

| Key | Action |
|-----|--------|
| `C-s c` | Reload config |
| `C-s :` | Command prompt |
| `C-s ?` | Help popup |

## Customization

The config is a single `~/.tmux.conf` file — no plugins, no external dependencies. Edit directly. Colors use the Catppuccin Mocha palette; search for `#1e1e2e` (base) or `#cba6f7` (mauve) to find the color definitions.
