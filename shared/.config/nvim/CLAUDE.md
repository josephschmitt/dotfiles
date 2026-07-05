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
6. **Keep CLAUDE.md current** — When adding/removing plugins, changing keybindings, or making architectural decisions, update this file in the same commit.

## Architecture

### File Structure
```
shared/.config/nvim/
├── init.lua                        # Stock kickstart.nvim (minimal tweaks)
├── lazy-lock.json                  # Plugin version pins
├── stylua.toml                     # Lua formatter config
├── CLAUDE.md                       # This file (agent guidelines)
├── README.md                       # User-facing documentation
└── lua/custom/
    ├── config.lua                  # Shared constants (neo-tree width, etc.)
    ├── lsp-servers.lua             # LSP server list (lspconfig names + config)
    └── plugins/                    # All plugin customizations go here
        ├── ai.lua                  # Claude Code integration
        ├── bufferline.lua          # Tab bar with ordinal numbering
        ├── cmdline.lua             # Command-line completion sources
        ├── colorscheme.lua         # Tokyonight moon style override
        ├── dashboard.lua           # Snacks dashboard keys
        ├── diagnostics.lua         # Inline diagnostic styling
        ├── filetree.lua            # Neo-tree file explorer
        ├── flash.lua               # Flash jump motions
        ├── git.lua                 # Gitsigns, mini.diff, diffview, lazygit
        ├── indent-blankline.lua    # Static indent guides
        ├── keymaps.lua             # Global keybindings
        ├── mason-auto-install.lua  # On-demand LSP server installation
        ├── mini.lua                # mini.nvim modules (ai, surround, statusline, move, bracketed, indentscope)
        ├── multicursor.lua         # Multi-cursor editing
        ├── notifier.lua            # Snacks toast notifications
        ├── options.lua             # Vim options, netrw replacement, autocmds
        ├── persistence.lua         # Session save/restore
        ├── picker.lua              # Snacks picker + JoeVim dashboard header
        ├── pj.lua                  # Project switcher
        ├── sortjson.lua            # JSON key sorting
        ├── tmux-navigator.lua      # Ctrl+hjkl tmux/nvim navigation
        ├── toggles.lua             # Toggle keybindings (wrap, inlay hints, format-on-save)
        └── which-key.lua           # Keybinding popup groups
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

## LSP & Formatting

### LSP Server Management
LSP servers are listed in `lua/custom/lsp-servers.lua` using **lspconfig names** (e.g., `ts_ls`, `jsonls`, `gopls`). The setup chain:

1. `lsp-servers.lua` — defines which servers to enable and their config
2. `init.lua` — calls `vim.lsp.enable()` for each server
3. `mason-auto-install.lua` — installs each server via Mason the first time its filetype is opened

**IMPORTANT**: `mason-auto-install` does NOT auto-detect servers from `lsp-servers.lua` or `vim.lsp.enable()` calls — it only installs packages explicitly listed in its own `opts.packages`, and it needs **Mason registry names**, which often differ from lspconfig names (e.g., `jsonls` -> `json-lsp`, `rust_analyzer` -> `rust-analyzer`). Whenever you add/remove a server in `lsp-servers.lua`, add/remove its Mason package name in `lua/custom/plugins/mason-auto-install.lua` too, or it will silently never get installed (LSP will fail with "X is not executable").

**Debugging checklist — if the user reports an LSP server won't install / errors as "not executable" / a language has no LSP features:**
1. Is the server in `lsp-servers.lua` (or `init.lua` for `lua_ls`)?
2. Is its **Mason registry name** (not lspconfig name — check `:Mason` or the registry) present in `mason-auto-install.lua`'s `opts.packages`?
3. If (1) but not (2), that's the bug — add it to `mason-auto-install.lua`.
4. Confirm with `:Mason` after opening a matching file, or check `~/.local/state/nvim/lsp.log` for "is not executable" errors.

4. `mason-tool-installer` — only for **non-LSP tools** (formatters, linters like `stylua`). Do NOT add lspconfig names here either — same registry-name mismatch applies.

### Formatting
Formatting uses `conform.nvim` with `lsp_format = 'fallback'`:
- If conform has a formatter configured for the filetype → uses that
- Otherwise → falls back to LSP formatting (if the attached server supports it)
- Manual format: `grf` (under the `gr` LSP group)
- Format-on-save is enabled by default, toggled via `<Leader>tf` (buffer) / `<Leader>tF` (global)

### Keybinding Prefixes
LSP and editing bindings use Neovim's native `g` prefixes (not `<Leader>`):

| Prefix | Group | Examples |
|--------|-------|----------|
| `gr` | LSP | `grn` rename, `gra` code action, `grr` references, `grd` definition, `grf` format |
| `gs` | Surround | `gsa` add, `gsd` delete, `gsr` replace |
| `gc` | Comment | `gcc` line, `gc` selection |

These are registered as which-key groups with icons in `which-key.lua`.

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
- [x] Git integration (gitsigns, diffview, mini.diff, lazygit, gitlinker)
- [x] Editor enhancements (flash, multicursor, mini.move/surround/ai)
- [x] Developer tools (claudecode, tiny-inline-diagnostic, sortjson)
- [x] Vim options (relativenumber, nowrap, cmdheight=0, etc.)
- [x] Dashboard (Snacks dashboard with custom JoeVim header)
- [x] Indent guides (indent-blankline + mini.indentscope)
- [x] Session persistence (persistence.nvim)
- [x] Auto-install LSP servers (mason-auto-install)
- [x] LSP formatting via conform.nvim (`grf`, format-on-save)
- [x] LSP server config (lua/custom/lsp-servers.lua)
