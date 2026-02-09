# Neovim Configuration

A bespoke [Neovim](https://neovim.io/) configuration built from scratch on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim).

![IMG_0586](https://github.com/user-attachments/assets/c60822c1-5e65-44c4-8f06-22be623d3fec)

## Why Build From Scratch?

After months of daily-driving [AstroNvim](https://astronvim.com/) and [LazyVim](https://www.lazyvim.org/), I had a config that worked — but I didn't *understand* it. Distros are powerful, but they're someone else's opinions wrapped in layers of abstraction. When something broke, I was debugging framework internals instead of Neovim.

This config is the opposite. Every plugin was added one at a time, tested, understood, and committed individually. The [commit history](https://github.com/josephschmitt/dotfiles/commits/main/shared/.config/nvim) reads like a build log — from stock kickstart.nvim to a full IDE in ~60 commits. Nothing is here "because the distro included it." Everything earns its place.

The AstroNvim and LazyVim configs still exist alongside this one (via `NVIM_APPNAME` isolation). They serve as feature references and fallbacks — but this is the daily driver.

## What Makes It Mine

### The Dashboard
A custom ASCII art header in ANSI Shadow style greets you on startup. Not the stock `NEOVIM`, not `AstroNvim` — this is my editor.

### Directory-Aware Startup
Run `nvim some/dir` and instead of the useless netrw file listing you get from stock Neovim, it sets the working directory, opens the Snacks dashboard in the main window, and focuses neo-tree in the sidebar. It required understanding the difference between Snacks dashboard's floating-window mode vs. its in-buffer rendering path — a subtle distinction that took several iterations to get right.

### Performance-First Plugin Loading
Dashboard startup loads only ~5 plugins in ~50ms. The entire LSP chain (lspconfig + mason + fidget + blink.cmp), treesitter, gitsigns, bufferline, and which-key all defer until you actually open a file or start typing. LazyVim achieves 33ms with a purpose-built lazy-loading framework; we get close with just careful `event` triggers on stock lazy.nvim.

### Smart Behaviors
- **Winbar** only appears when you have multiple splits (no wasted space with one window)
- **Bufferline** hides when only one buffer is open
- **Neo-tree** auto-opens on wide screens and closes on narrow ones
- **mini.indentscope** uses a `draw.predicate` to skip non-file buffers — autocmd-based approaches lose the race against dashboard buffer initialization

### Unified Keybinding Philosophy
AstroNvim's keybinding structure was the starting point, but adapted to be more discoverable. Everything lives under `<Space>` with which-key's helix-style popup. Icons are embedded directly in group names (a workaround for `icons.mappings=false` blocking explicit icon properties).

## Launch

```bash
nvim              # Default (no NVIM_APPNAME needed)
vim               # Alias — same config
lazyvim           # LazyVim config (NVIM_APPNAME=lazyvim)
astrovim          # AstroNvim config (NVIM_APPNAME=astronvim)
```

## Architecture

Stock `init.lua` from kickstart.nvim with all customizations in `lua/custom/plugins/`. Each file is one feature, one concern. When a custom file references the same plugin as `init.lua`, lazy.nvim merges the specs — so custom `opts` and `config` override stock ones without modifying the upstream file.

```
lua/custom/plugins/
├── ai.lua                  # Claude Code integration
├── bufferline.lua          # Tab bar with ordinal numbers
├── cmdline.lua             # Command-line completion
├── colorscheme.lua         # Tokyonight moon + custom highlights
├── dashboard.lua           # Snacks dashboard config
├── diagnostics.lua         # Powerline-style inline diagnostics
├── filetree.lua            # Neo-tree with auto-open/close
├── flash.lua               # Label-based jump motions
├── git.lua                 # Gitsigns, mini.diff, diffview, lazygit
├── indent-blankline.lua    # Static indent guides (all levels)
├── keymaps.lua             # Core keybindings (jk escape, etc.)
├── mason-auto-install.lua  # On-demand LSP server installation
├── mini.lua                # Statusline, surround, text objects, move, indentscope
├── multicursor.lua         # Multi-cursor editing
├── notifier.lua            # Toast notifications
├── options.lua             # Vim options, netrw replacement, autocmds
├── persistence.lua         # Session save/restore with neo-tree cleanup
├── picker.lua              # Snacks picker (replaced Telescope) + dashboard header
├── pj.lua                  # Project jumping
├── sortjson.lua            # JSON key sorting
├── tmux-navigator.lua      # Seamless Ctrl+hjkl between tmux/nvim
├── toggles.lua             # Toggle keybindings (format, wrap, hints, etc.)
└── which-key.lua           # Helix-style popup with icon groups
```

## Plugins

| Plugin | Purpose | Loads |
|--------|---------|-------|
| tokyonight.nvim | Colorscheme (moon style) | Startup |
| snacks.nvim | Dashboard, picker, notifications, lazygit | Startup |
| mini.nvim | Statusline, surround, text objects, move, indentscope | Startup |
| nvim-lspconfig | Language server support | File open |
| mason.nvim + mason-auto-install | LSP/tool install (on-demand per filetype) | With LSP |
| nvim-treesitter | Syntax highlighting | File open |
| blink.cmp | Autocompletion | Insert mode |
| neo-tree.nvim | File explorer sidebar | On keypress |
| bufferline.nvim | Tab bar with ordinal numbers | Second buffer |
| gitsigns.nvim | Git gutter signs + hunk operations | File open |
| mini.diff | Inline diff overlay | File open |
| diffview.nvim | Full-screen side-by-side diff viewer | On command |
| which-key.nvim | Keybinding popup (helix preset) | VeryLazy |
| flash.nvim | Label-based jump motions | VeryLazy |
| claudecode.nvim | Claude Code WebSocket integration | VeryLazy |
| persistence.nvim | Session save/restore per directory | File open |
| conform.nvim | Format on save | File save |
| indent-blankline.nvim | Static indent guides at every level | File open |
| tiny-inline-diagnostic.nvim | Powerline-style diagnostic messages | VeryLazy |
| multicursor.nvim | Multi-cursor editing | On keypress |
| vim-tmux-navigator | Ctrl+hjkl across tmux and nvim splits | On keypress |

## Key Bindings

Leader key: **Space**

| Key | Action |
|-----|--------|
| `<Leader>s` | Save buffer |
| `<Leader>c` | Close buffer |
| `<Leader>q` | Quit window |
| `<Leader>h` | Home screen (dashboard) |
| `<Leader>n` | New file |
| `<Leader>r` | Rename file |
| `<Leader><Space>` | Smart picker |
| `<Leader>ff` | Find files |
| `<Leader>fg` | Find by grep |
| `<Leader>fb` | Find buffers |
| `<Leader>fr` | Find recent files |
| `<Leader>ee` | Toggle file explorer |
| `<Leader>ef` | Find file in explorer |
| `S-h` / `S-l` | Previous / next buffer |
| `Ctrl+1-9` | Jump to buffer by number |
| `<Leader>gs` | Stage git hunk |
| `<Leader>gd` | Toggle diff overlay |
| `<Leader>gg` | Lazygit |
| `<Leader>ac` | Launch Claude in tmux split |
| `gsa` / `gsd` / `gsr` | Surround add / delete / replace |

Press `<Space>` and wait for the which-key popup to see everything.

## Performance

Dashboard loads **~5 plugins** in **~50ms**. Everything else is lazy-loaded:

- **File-editing plugins** (LSP, treesitter, gitsigns, indent guides) load on `BufReadPost`
- **Completion** loads on `InsertEnter`
- **UI chrome** (which-key, diagnostics, flash) loads on `VeryLazy`
- **On-demand tools** (neo-tree, diffview, multicursor) load on first keypress

Run `:Lazy` to see plugin load timing and counts.
