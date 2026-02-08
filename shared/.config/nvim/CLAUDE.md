# Agent Guidelines for Custom Neovim Configuration

## Philosophy: Bespoke, Not Replicated

This is a **from-scratch custom Neovim configuration** built on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim). The goal is a config where every plugin and setting is intentionally chosen and fully understood — not a clone of any distro.

The existing AstroNvim config (`shared/.config/astronvim/`) serves as **inspiration** for features and keybindings, but we are NOT trying to replicate it. Each feature is evaluated independently and added only when the user understands what it does and why they want it.

## Guiding Principles

1. **Understand before adding** — Explain what every plugin does and why each config option exists. The user wants to learn, not just copy settings.
2. **One feature at a time** — Add features incrementally, test each one, commit, then move on. No large batch changes.
3. **Stock kickstart as foundation** — Keep `init.lua` as close to upstream kickstart.nvim as possible. All customizations go in `lua/custom/plugins/`.
4. **Simplicity over cleverness** — Prefer straightforward configs. Don't over-engineer or add options "just in case."
5. **Commit hygiene** — Each feature gets its own commit. Include `lazy-lock.json` changes. Amend when restructuring.

## Architecture

### File Structure
```
shared/.config/nvim/
├── init.lua                        # Stock kickstart.nvim (minimal tweaks)
├── lazy-lock.json                  # Plugin version pins
├── stylua.toml                     # Lua formatter config
├── CLAUDE.md                       # This file
└── lua/custom/plugins/             # All customizations go here
    ├── dashboard.lua               # Snacks dashboard + ASCII art header
    ├── colorscheme.lua             # Tokyonight moon style override
    └── (future feature files...)
```

### How Custom Plugins Work
Kickstart.nvim includes `{ import = 'custom.plugins' }` in its lazy.nvim setup, which auto-loads every `.lua` file in `lua/custom/plugins/`. Each file returns a table of [lazy.nvim plugin specs](https://lazy.folke.io/spec).

When a custom plugin file references the same plugin as `init.lua` (e.g., `folke/tokyonight.nvim`), lazy.nvim **merges** the specs — the custom `opts` and `config` override the stock ones.

### Adding a New Feature
1. Create `lua/custom/plugins/<feature>.lua`
2. Return a table of plugin specs
3. Test with `kickstart` alias
4. Commit the new file + updated `lazy-lock.json`

### What NOT to Do
- Don't modify `init.lua` unless absolutely necessary (e.g., enabling the custom plugins import)
- Don't add plugins without explaining what they do
- Don't batch multiple unrelated features into one file
- Don't assume AstroNvim's approach is the right one — evaluate each choice

## Reference: AstroNvim Features to Evaluate

Features from the AstroNvim config that may be worth porting (each evaluated individually):

- [ ] File tree (neo-tree)
- [ ] File/buffer picker (Snacks picker vs Telescope)
- [ ] Buffer line / tab bar
- [ ] Keybinding structure (which-key groups, leader mappings)
- [ ] Git integration (gitsigns, diffview, mini.diff)
- [ ] Editor enhancements (flash, yazi, multicursor, mini.move/surround/ai)
- [ ] Developer tools (claudecode, tiny-inline-diagnostic, sortjson)
- [ ] Vim options (relativenumber, signcolumn, nowrap, etc.)

## Shell Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `kickstart` | `command nvim` | Launch this config (default nvim) |
| `knvim` | `command nvim` | Short alias |

This config uses the default `~/.config/nvim/` path, so bare `nvim` without `NVIM_APPNAME` loads it. The aliases exist for clarity while developing alongside AstroNvim and LazyVim.
