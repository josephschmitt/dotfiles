# AstroVim Configuration

**NOTE:** This is for AstroNvim v5+

Custom [AstroNvim](https://github.com/AstroNvim/AstroNvim) configuration with enhanced keybindings, custom plugins, and theme customizations.

## 🛠️ Installation

#### Make a backup of your current nvim and shared folder

```shell
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak
mv ~/.cache/nvim ~/.cache/nvim.bak
```

#### Create a new user repository from this template

Press the "Use this template" button above to create a new repository to store your user configuration.

You can also just clone this repository directly if you do not want to track your user configuration in GitHub.

#### Clone the repository

```shell
git clone https://github.com/<your_user>/<your_repository> ~/.config/nvim
```

#### Start Neovim

```shell
nvim
```

## ✨ Features

### Theme & UI
- **Colorscheme**: Catppuccin Mocha (with Tokyonight Night also available)
- **Dashboard**: Custom ASCII art header using `ascii.nvim`
- **Diagnostics**: Inline diagnostics with `tiny-inline-diagnostic.nvim` (powerline preset)
- **File Explorer**: Neo-tree with 40-column width, follows current file
- **Buffer Navigation**: Ordinal numbers in bufferline, `Ctrl+1-9` for quick buffer switching

### Editor Enhancements
- **Multi-cursor**: Full multi-cursor support via `multicursor.nvim`
- **Smart Text Objects**:
  - `mini.ai` - AI-powered text objects (indent, treesitter, patterns)
  - `mini.surround` - Surround text with brackets/quotes
  - `vim-textobj-fold` - Fold-based text objects
- **Motion**: Flash.nvim for enhanced navigation
- **File Manager**: Yazi integration for terminal file management
- **Code Diff**: CodeDiff viewer for comparing code changes

### LSP & Formatting
- **Format on Save**: Enabled globally (configurable per-filetype)
- **Codelens**: Auto-refresh on InsertLeave and BufEnter
- **Semantic Tokens**: Enabled by default

### Vim Options
- Relative line numbers enabled
- Line wrapping disabled
- Sign column always visible
- Spell checking disabled by default

## 🎨 Theme

**Active**: Tokyonight Moon
**Available**: Catppuccin Mocha, Tokyonight Night

Change theme in `lua/plugins/astroui.lua`:
```lua
opts = {
  colorscheme = "tokyonight-moon", -- or "catppuccin-mocha", "tokyonight-night"
}
```

## 🔌 Plugins

### Community Plugins (from AstroCommunity)
- `astrocommunity.colorscheme.catppuccin`
- `astrocommunity.colorscheme.tokyonight-nvim`
- `astrocommunity.pack.lua`
- `astrocommunity.motion.flash-nvim`
- `astrocommunity.file-explorer.yazi-nvim`
- `astrocommunity.diagnostics.tiny-inline-diagnostic-nvim`
- `astrocommunity.git.codediff-nvim`

### Custom Plugins
| Plugin | Purpose | Status | Source |
|--------|---------|--------|--------|
| `bufferline.nvim` | Buffer tabs | Active | Built-in (AstroNvim default) |
| `multicursor.nvim` | Multi-cursor editing | Active | Custom |
| `yazi.nvim` | Terminal file manager integration | Active | AstroCommunity (customized) |
| `modes.nvim` | Mode-based color highlighting | Disabled | Custom |
| `tiny-inline-diagnostic.nvim` | Inline diagnostic messages | Active | AstroCommunity (customized) |
| `codediff.nvim` | Code diff viewer | Active | AstroCommunity (customized) |
| `sortjson.nvim` | JSON sorting utilities | Active | Custom |
| `vim-textobj-fold` | Fold text objects | Active | Custom |
| `mini.ai` | Smart text objects | Active | Custom |
| `mini.surround` | Surround operations | Active | Custom |
| `ascii.nvim` | ASCII art for dashboard | Active | Custom |
| `snacks.nvim` | Dashboard (customized with ASCII art) | Active | Built-in (customized) |

## ⌨️ Keybindings

### Leader Keys
- **Leader**: `<Space>`
- **Local Leader**: `,`

### Basic Editing
| Keybinding | Mode | Action |
|-----------|------|--------|
| `<leader><space>` | Normal | Smart picker (find files/buffers) |
| `<leader>s` | Normal | Save buffer |
| `U` | Normal | Redo |
| `jk`, `kj`, `jj` | Insert | Exit insert mode |
| `<C-a>` | Normal | Select all |
| `gV` | Normal | Select all |
| `<C-c>` | Normal, Visual | Comment line(s) |
| `<` | Normal | Unindent line |
| `>` | Normal | Indent line |
| `gh` | Normal, Visual | Go to beginning of line |
| `gl` | Normal, Visual | Go to end of line |

### Buffer Navigation
| Keybinding | Action |
|-----------|--------|
| `<S-h>` | Previous buffer |
| `<S-l>` | Next buffer |
| `]b` | Next buffer |
| `[b` | Previous buffer |
| `<leader>ba` | Close all buffers |
| `<leader>bd` | Close buffer from tabline (interactive picker) |
| `<leader>bD` | Close current buffer |
| `<leader>be` | Open buffer explorer (Neo-tree) |

### File Explorer
| Keybinding | Action |
|-----------|--------|
| `<leader>e` | Toggle Neo-tree file explorer |
| `<leader>be` | Neo-tree buffer explorer |
| `<leader>ge` | Neo-tree git status explorer |
| `<leader>fy`, `<leader>y` | Open Yazi (current file) |
| `<leader>fY`, `<leader>Y` | Open Yazi (cwd) |

### Window Management (`<leader>w`)
| Keybinding | Action |
|-----------|--------|
| `<leader>w` | Show window commands (which-key) |
| **Split Creation** | |
| `<leader>ws` | Split horizontal |
| `<leader>wv` | Split vertical |
| **Window Closing/Management** | |
| `<leader>wc` | Close window |
| `<leader>wo` | Close other windows |
| `<leader>w=` | Equalize window sizes |
| **Window Movement** | |
| `<leader>wH` | Move window left |
| `<leader>wJ` | Move window down |
| `<leader>wK` | Move window up |
| `<leader>wL` | Move window right |
| `<leader>wr` | Rotate windows |
| `<leader>wx` | Swap with next window |
| **Window Resizing** | |
| `<leader>w+` | Increase height (+5 lines) |
| `<leader>w-` | Decrease height (-5 lines) |
| `<leader>w>` | Increase width (+5 cols) |
| `<leader>w<` | Decrease width (-5 cols) |
| **Quick Access** | |
| `gw` | Enter window mode (access `<C-w>` commands) |
| `<A-w>` | Switch to next window |

### Tab Management (`<leader><Tab>`)
| Keybinding | Action |
|-----------|--------|
| `<leader><Tab>` | Show tab commands (which-key) |
| **Tab Creation/Closing** | |
| `<leader><Tab>n` | New tab |
| `<leader><Tab>c` | Close tab |
| `<leader><Tab>o` | Close other tabs |
| **Tab Navigation** | |
| `<leader><Tab>]` | Next tab |
| `<leader><Tab>[` | Previous tab |
| `<leader><Tab>l` | Last tab |
| `<leader><Tab>f` | First tab |
| **Tab Movement** | |
| `<leader><Tab>>` | Move tab right |
| `<leader><Tab><` | Move tab left |

### Multi-Cursor (`<leader>m`)
| Keybinding | Mode | Action |
|-----------|------|--------|
| `<up>` | Normal, Visual | Add cursor above |
| `<down>` | Normal, Visual | Add cursor below |
| `<M-Down>` | Normal, Visual | Add cursor for next word/selection match |
| `<M-Up>` | Normal, Visual | Add cursor for previous word/selection match |
| `<S-Down>` | Normal, Visual | Skip cursor down |
| `<S-Up>` | Normal, Visual | Skip cursor up |
| `<leader>ma` | Normal, Visual | Add cursors for all word/selection matches |
| `<leader>mc` | Normal | Add cursors for motion |
| `<leader>mo` | Normal, Visual | Add cursors for match operator |
| `<leader>mA` | Normal, Visual | Add cursors to every search result |
| `<leader>mn` | Normal | Add cursor and jump to next search result |
| `<leader>mN` | Normal | Add cursor and jump to previous search result |
| `<leader>ms` | Normal | Jump to next search result without adding cursor |
| `<leader>mS` | Normal | Jump to previous search result without adding cursor |
| `<leader>mt` | Visual | Rotate text between cursors forward |
| `<leader>mT` | Visual | Rotate text between cursors backward |
| `I` | Visual | Insert at beginning of visual selections |
| `A` | Visual | Append at end of visual selections |
| **Multi-cursor Mode** | | *(Active when cursors exist)* |
| `<left>` | Normal, Visual | Previous cursor |
| `<right>` | Normal, Visual | Next cursor |
| `<leader>x` | Normal, Visual | Delete cursor |
| `<esc>` | Normal | Toggle cursors enable/clear |

### Text Objects
| Keybinding | Mode | Action |
|-----------|------|--------|
| `zi` | Visual, Operator | Inside fold (strict) |
| `za` | Visual, Operator | Around fold |
| *(mini.ai provides additional smart text objects)* | | |
| *(mini.surround provides surround operations)* | | |

### LSP
| Keybinding | Action |
|-----------|--------|
| `gD` | Go to declaration |
| `<leader>uY` | Toggle LSP semantic highlighting (buffer) |

### Clipboard
| Keybinding | Mode | Action |
|-----------|------|--------|
| `<D-v>` | Insert, Terminal | Paste from clipboard (macOS Cmd+V) |

### Visual Mode
| Keybinding | Action |
|-----------|--------|
| `<S-v>` | Select down (Helix-like) |

## 📁 Configuration Structure

```
lua/
├── community.lua           # AstroCommunity imports
├── lazy_setup.lua         # Lazy.nvim configuration
└── plugins/
    ├── astrocore.lua      # Core features, options, keymaps
    ├── astrolsp.lua       # LSP configuration (DISABLED - activate by removing line 1)
    ├── astroui.lua        # UI & colorscheme
    ├── filetree.lua       # Neo-tree configuration
    ├── mason.lua          # Mason LSP installer config
    ├── none-ls.lua        # null-ls/none-ls configuration
    ├── treesitter.lua     # Treesitter parsers (DISABLED - activate by removing line 1)
    └── user.lua           # Custom plugins (bufferline, multicursor, yazi, etc.)
```

### Key Configuration Files

#### `astrocore.lua`
Core AstroNvim configuration including:
- Vim options (line numbers, wrapping, etc.)
- All custom keymaps
- Feature flags (autopairs, completion, diagnostics)

#### `astroui.lua`
UI configuration:
- Active colorscheme
- Highlight overrides
- Custom icons

#### `user.lua`
Custom plugin configurations:
- Bufferline with ordinal numbers
- Multi-cursor support
- Yazi file manager
- CodeDiff viewer
- Mini.ai and Mini.surround
- Text object plugins
- Dashboard ASCII art

#### `community.lua`
Imports from AstroCommunity:
- Colorschemes (Catppuccin, Tokyonight)
- Lua language pack
- Flash.nvim motion

## 🔧 Customization Tips

### Change Colorscheme
Edit `lua/plugins/astroui.lua`:
```lua
opts = {
  colorscheme = "catppuccin-mocha", -- or "tokyonight-moon", "tokyonight-night"
}
```

### Add New Keymaps
Edit `lua/plugins/astrocore.lua` in the `mappings` table:
```lua
mappings = {
  n = {  -- normal mode
    ["<Leader>x"] = { "<Cmd>command<CR>", desc = "Description" },
  },
}
```

### Add Community Plugins
Edit `lua/community.lua`:
```lua
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.typescript" }, -- Example
}
```
Browse available plugins at: https://github.com/AstroNvim/astrocommunity

### Add Custom Plugins
Edit `lua/plugins/user.lua`:
```lua
{
  "plugin/name",
  opts = { ... },
}
```

### Enable LSP Configuration
The `astrolsp.lua` file is currently disabled. To activate:
1. Edit `lua/plugins/astrolsp.lua`
2. Remove line 1: `if true then return {} end`
3. Restart Neovim

### Enable Treesitter Parsers
The `treesitter.lua` file is currently disabled. To activate:
1. Edit `lua/plugins/treesitter.lua`
2. Remove line 1: `if true then return {} end`
3. Add desired parsers to `ensure_installed`
4. Restart Neovim

## 📝 Notes

- **Leader key**: `<Space>` (defined in `lua/lazy_setup.lua`)
- **Local leader**: `,` (defined in `lua/lazy_setup.lua`)
- **Format on save**: Enabled globally (configure in `astrolsp.lua`)
- **Large file threshold**: 256KB or 10,000 lines (disables heavy features)
- **Disabled RTP plugins**: gzip, netrw, tar, tohtml, zip (for performance)

## 🐛 Known Issues

- **modes.nvim**: Disabled due to startup messages. Re-enable in `lua/plugins/user.lua` (line 177) if desired.

## 📚 Resources

- [AstroNvim Documentation](https://docs.astronvim.com/)
- [AstroCommunity Plugins](https://github.com/AstroNvim/astrocommunity)
- [Lazy.nvim Plugin Manager](https://github.com/folke/lazy.nvim)
