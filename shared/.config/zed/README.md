# Zed Editor Configuration

Configuration for [Zed](https://zed.dev/) - a high-performance, multiplayer code editor built in Rust. This config provides a Neovim-like experience with modern IDE features.

## Features

- **Vim mode** - Full Vim keybindings with relative line numbers
- **AI assistance** - Integrated GitHub Copilot and Claude Sonnet 4
- **Space-based keymaps** - Spacemacs/LazyVim-inspired leader key workflow
- **Git integration** - Built-in git panel and lazygit integration
- **Catppuccin theme** - Consistent theming with Monaco Nerd Font
- **Smart editing** - AI-powered edit predictions via Copilot

## Theme & Appearance

- **Theme**: Catppuccin Mocha (dark) / One Light (light)
- **Icon Theme**: Material Icon Theme
- **Buffer Font**: Monaco Nerd Font, 13pt (ligatures disabled)
- **UI Font**: Monaco Nerd Font, 15pt
- **Line numbers**: Relative (toggles with Vim mode)
- **Whitespace**: Always visible
- **Indent guides**: Indent-aware coloring

## Vim Configuration

### Cursor Shapes
- **Normal mode**: Block cursor
- **Insert mode**: Bar cursor
- **Visual mode**: Underline cursor
- **Replace mode**: Hollow cursor

### Features
- System clipboard integration on yank
- Relative line numbers
- Custom Vim keybindings (see keymap.json)

## Key Bindings

All custom keybindings use `space` as the leader key.

### Core Navigation
- `space space` - File finder (fuzzy search)
- `space e` - Toggle file explorer
- `space ,` - Tab switcher
- `ctrl-h/j/k/l` - Navigate between panes
- `ctrl-/` - Toggle terminal

### Buffer Management
- `space b d` - Close current buffer
- `space b q` - Close inactive buffers
- `space b n` - New file
- `space b b` - Alternate file (last buffer)
- `space 1-9` - Jump to buffer 1-9
- `space 0` - Jump to last buffer
- `] b` / `[ b` - Next/previous buffer

### File Operations
- `space f f` - Find file
- `space f n` - New file
- `space f p` - Open recent project

### Search
- `space /` - Search in all files
- `space s g` - Search in all files
- `space s w` - Search word under cursor (current buffer)
- `space s W` - Search word under cursor (all buffers)
- `space s b` - Search in current buffer
- `space s d` - Show diagnostics
- `space s s` - Toggle outline

### Git Operations
- `space g g` - Open lazygit
- `space g b` - Git blame
- `space g h d` - Expand all diff hunks
- `space g h D` - Show diff
- `space g h r` - Restore hunk
- `space g h R` - Restore file
- `] h` / `[ h` - Next/previous hunk
- `cmd-shift-g` - Toggle git panel
- `q` (in git panel) - Close git panel

### AI Assistant
- `space a a` - Toggle AI assistant focus
- `space a e` - Inline assist
- `space a t` - Toggle right dock (assistant panel)
- `cmd-k` - Toggle right dock
- `ctrl-\` - Toggle right dock

### Code Actions
- `space c a` - Toggle code actions
- `space c r` - Rename symbol
- `space c f` - Format code
- `g r` - Find all references

### Window Management
- `space w s` / `space -` - Split down
- `space w v` / `space |` - Split right
- `space w c` / `space w d` - Close all panes

### Diagnostics Navigation
- `] d` / `[ d` - Next/previous diagnostic
- `] e` / `[ e` - Next/previous error
- `] q` / `[ q` - Next/previous excerpt

### Toggle Settings
- `space u i` - Toggle inlay hints
- `space u w` - Toggle soft wrap

### Markdown
- `space m p` - Markdown preview
- `space m P` - Markdown preview (side by side)

### Miscellaneous
- `space q q` - Quit Zed
- `space t` - Toggle terminal
- `:` (in project panel) - Command palette

## Editor Settings

- **Tab size**: 2 spaces
- **Preferred line length**: 100 characters
- **Format on save**: Disabled (manual formatting with `space c f`)
- **Soft wrap**: Editor width
- **Project panel width**: 300px
- **Gutter**: Minimum 3 digits for line numbers

## File Explorer (Project Panel)

Vim-style navigation when focused:

- `j/k` - Move down/up
- `h/l` - Collapse/expand directory
- `g g` / `shift-g` - First/last item
- `enter` / `o` / `t` / `v` - Open file
- `a` - New file
- `shift-a` - New directory
- `r` - Rename
- `d` - Delete
- `c` / `x` / `p` - Copy/cut/paste
- `/` - Search in directory
- `-` - Select parent directory
- `q` - Close file explorer

## AI Configuration

- **Default model**: Claude Sonnet 4 (via Copilot Chat)
- **Edit predictions**: Powered by GitHub Copilot
- **Inline assistance**: Available via `space a e` or `cmd-l`

## Vim Enhancements

### Sneak Motion
- `s{char}{char}` - Sneak forward
- `shift-s{char}{char}` - Sneak backward

### Custom Motions
- `g l` - End of line
- `g h` - First non-whitespace character
- `g shift-h` - Start of line
- `shift-u` - Redo
- `shift-j/k` (visual mode) - Move line down/up

### Centering
- `ctrl-d` / `ctrl-u` - Scroll half-page with cursor centered
- `n` / `shift-n` - Next/previous search result (centered)
- `shift-g` - Go to end of file (centered)

## Task Integration

### Lazygit
The configuration includes a task to launch lazygit from within Zed (`space g g`).

## Related Tools

- **Neovim** - Primary editor (this is a fallback/alternative)
- **GitHub Copilot** - AI pair programmer
- **lazygit** - Terminal UI for git commands
- **Monaco Nerd Font** - Font with icon support

## Installation

```bash
# Install Zed
brew install zed

# Configuration is automatically loaded from ~/.config/zed/
# This dotfiles repo provides settings.json and keymap.json
```

## Notes

- Format on save is disabled - use `space c f` to format manually
- Ligatures are disabled in Monaco Nerd Font for better code clarity
- Git status indicators appear in tabs
- Diagnostics only show errors in tabs (warnings hidden)
