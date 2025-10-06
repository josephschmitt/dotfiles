# Helix Editor Configuration

Configuration for [Helix](https://helix-editor.com) - a modern modal text editor with built-in LSP support and tree-sitter syntax highlighting.

## Features

- **Modal editing** with vim-like keybindings
- **Built-in LSP** support for multiple languages
- **Tree-sitter** syntax highlighting and code navigation
- **Multiple cursors** and selections
- **Yazi integration** for file browsing
- **LazyGit integration** for version control
- **Catppuccin Mocha theme**

## File Structure

- `config.toml` - Main editor configuration and keybindings
- `languages.toml` - Language server and formatter configurations
- `ignore` - Files to exclude from file picker
- `get_git_permalink.sh` - Generate GitHub permalinks for current line
- `yazi-picker.sh` - Yazi file picker integration script

## Key Configuration

### Appearance
- **Theme**: Catppuccin Mocha
- **Line numbers**: Relative (for vim-style navigation)
- **Ruler**: 100 character column guide
- **Text width**: 100 characters
- **Cursor shapes**: Bar (insert), Block (normal), Underline (select)

### Notable Settings
- **Bufferline**: Shows multiple buffers as tabs
- **Color modes**: Visual mode indicator
- **Soft wrap**: Enabled at text width
- **Indent guides**: Visible
- **Inline diagnostics**: Shown as hints

## Custom Keybindings

### Buffer Navigation
- `Shift+H` - Previous buffer
- `Shift+L` - Next buffer
- `Space+x` - Close current buffer

### Tmux-style Pane Navigation
Works in both normal and insert modes:
- `Ctrl+H` - Jump to left pane
- `Ctrl+J` - Jump to bottom pane
- `Ctrl+K` - Jump to top pane
- `Ctrl+L` - Jump to right pane

### Sub-word Movement
Navigate camelCase and snake_case:
- `Alt+W` - Next sub-word start
- `Alt+B` - Previous sub-word start
- `Alt+E` - Next sub-word end

### File Explorer (Yazi)
- `Space+e` - Open Yazi from current file's directory
- `Space+E` - Open Yazi from workspace root

### Git Integration
- `Space+l` - Open LazyGit in workspace
- `Space+L` - Copy GitHub permalink to clipboard (current line)

### Other
- `Ctrl+R` - Reload configuration
- `Esc` - Collapse selection to primary
- `X` - Extend selection to line above

## Language Support

Configured LSPs and formatters in `languages.toml` for:
- TypeScript/JavaScript
- Rust
- Python
- And more

## Integration

### With Yazi
Helix opens Yazi as a file picker, allowing visual file browsing and selection. Files chosen in Yazi open directly in Helix.

### With LazyGit
Opens LazyGit in workspace directory, saves all buffers first, then reloads files after Git operations complete.

### With Tmux
Helix pane navigation keybindings mirror tmux navigation, creating a seamless experience when running inside tmux panes.

## Installation

Installed via main dotfiles setup:

```bash
stow shared
```

## Usage

Helix serves as the secondary editor (Neovim is primary). It's particularly useful for:
- Quick edits on remote systems (simpler setup than Neovim)
- Files where you want built-in LSP without plugin configuration
- Situations where you want a "batteries included" modal editor
