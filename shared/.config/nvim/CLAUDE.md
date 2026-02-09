# Agent Guidelines for Custom Neovim Configuration

## Philosophy: Bespoke, Not Replicated

This is a **from-scratch custom Neovim configuration** built on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim). The goal is a config where every plugin and setting is intentionally chosen and fully understood — not a clone of any distro.

The existing AstroNvim config (`shared/.config/astronvim/`) serves as **inspiration** for features and keybindings, but we are NOT trying to replicate it. Each feature is evaluated independently and added only when the user understands what it does and why they want it.

## Guiding Principles

1. **Understand before adding** — Explain what every plugin does and why each config option exists. The user wants to learn, not just copy settings.
2. **One feature at a time** — Add features incrementally, test each one, commit, then move on. No large batch changes.
3. **Stock kickstart as foundation** — Keep `init.lua` as close to upstream kickstart.nvim as possible. All customizations go in `lua/custom/plugins/`.
4. **Simplicity over cleverness** — Prefer straightforward configs. Don't over-engineer or add options "just in case."
5. **Commit hygiene** — Each feature gets its own commit. Include `lazy-lock.json` changes.

## Architecture

### File Structure
```
shared/.config/nvim/
├── init.lua                        # Stock kickstart.nvim (minimal tweaks)
├── lazy-lock.json                  # Plugin version pins
├── stylua.toml                     # Lua formatter config
├── CLAUDE.md                       # This file (agent guidelines)
├── README.md                       # User-facing documentation
└── lua/custom/plugins/             # All customizations go here
    ├── ai.lua                      # Claude Code integration
    ├── bufferline.lua              # Tab bar with ordinal numbering
    ├── cmdline.lua                 # Command-line completion sources
    ├── colorscheme.lua             # Tokyonight moon style override
    ├── dashboard.lua               # Snacks dashboard keys
    ├── diagnostics.lua             # Inline diagnostic styling
    ├── filetree.lua                # Neo-tree file explorer
    ├── flash.lua                   # Flash jump motions
    ├── git.lua                     # Gitsigns, mini.diff, diffview, lazygit
    ├── indent-blankline.lua        # Static indent guides
    ├── keymaps.lua                 # Global keybindings
    ├── mason-auto-install.lua      # On-demand LSP server installation
    ├── mini.lua                    # mini.nvim modules (ai, surround, statusline, move, bracketed, indentscope)
    ├── multicursor.lua             # Multi-cursor editing
    ├── notifier.lua                # Snacks toast notifications
    ├── options.lua                 # Vim options, netrw replacement, autocmds
    ├── persistence.lua             # Session save/restore
    ├── picker.lua                  # Snacks picker + JoeVim dashboard header
    ├── pj.lua                      # Project switcher
    ├── sortjson.lua                # JSON key sorting
    ├── tmux-navigator.lua          # Ctrl+hjkl tmux/nvim navigation
    ├── toggles.lua                 # Toggle keybindings (wrap, inlay hints, format-on-save)
    └── which-key.lua               # Keybinding popup groups
```

### How Custom Plugins Work
Kickstart.nvim includes `{ import = 'custom.plugins' }` in its lazy.nvim setup, which auto-loads every `.lua` file in `lua/custom/plugins/`. Each file returns a table of [lazy.nvim plugin specs](https://lazy.folke.io/spec).

When a custom plugin file references the same plugin as `init.lua` (e.g., `folke/tokyonight.nvim`), lazy.nvim **merges** the specs — the custom `opts` and `config` override the stock ones.

### Adding a New Feature
1. Create `lua/custom/plugins/<feature>.lua`
2. Return a table of plugin specs
3. Test with `nvim`
4. Commit the new file + updated `lazy-lock.json`

### What NOT to Do
- Don't modify `init.lua` unless absolutely necessary (e.g., adding a lazy-loading event)
- Don't add plugins without explaining what they do
- Don't batch multiple unrelated features into one file
- Don't assume AstroNvim's approach is the right one — evaluate each choice

## Performance: Lazy-Loading Guidelines

Dashboard startup should load minimal plugins (~5). Every plugin must justify loading before the user opens a file.

### Lazy-loading triggers by category

| Category | Event / Trigger | Examples |
|----------|----------------|----------|
| **Must load at startup** | No event needed | colorscheme, statusline (mini.nvim), dashboard (snacks.nvim) |
| **File-editing plugins** | `event = { "BufReadPost", "BufNewFile" }` | LSP, treesitter, gitsigns, guess-indent, todo-comments |
| **Completion** | `event = { "InsertEnter", "CmdlineEnter" }` | blink.cmp, LuaSnip |
| **Non-critical UI** | `event = "VeryLazy"` | which-key, claudecode, flash, diagnostics |
| **Multi-buffer UI** | `event = "BufAdd"` | bufferline |
| **On-demand tools** | `cmd` or `keys` triggers | neo-tree, diffview, sortjson, pj |

### Rules for new plugins
1. **Always add a lazy-loading trigger** — never leave a plugin without `event`, `cmd`, `keys`, or `ft`
2. **Ask**: "Does this need to load before the user opens a file?" If no → defer it
3. **Dependencies inherit**: if plugin A depends on B, B loads when A loads (no need to eager-load B separately)
4. **Test with `:Lazy`** — check startup plugin count after adding

## Shell Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `nvim` / `vim` | `command nvim` | Default — launches this config |
| `lazyvim` | `NVIM_APPNAME=lazyvim command nvim` | Launch LazyVim config |
| `astrovim` | `NVIM_APPNAME=astronvim command nvim` | Launch AstroNvim config |

This config uses the default `~/.config/nvim/` path, so bare `nvim` without `NVIM_APPNAME` loads it.

## Reference: Ported Features

Features ported from AstroNvim/LazyVim (each evaluated and adapted individually):

- [x] File tree (neo-tree)
- [x] File/buffer picker (Snacks picker, replaced Telescope)
- [x] Buffer line / tab bar (bufferline.nvim)
- [x] Keybinding structure (which-key groups, leader mappings)
- [x] Git integration (gitsigns, diffview, mini.diff, lazygit)
- [x] Editor enhancements (flash, multicursor, mini.move/surround/ai)
- [x] Developer tools (claudecode, tiny-inline-diagnostic, sortjson)
- [x] Vim options (relativenumber, nowrap, cmdheight=0, etc.)
- [x] Dashboard (Snacks dashboard with custom JoeVim header)
- [x] Indent guides (indent-blankline + mini.indentscope)
- [x] Session persistence (persistence.nvim)
- [x] Auto-install LSP servers (mason-auto-install)
