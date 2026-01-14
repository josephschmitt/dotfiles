# AstroNvim Template

**NOTE:** This is for AstroNvim v5+

A template for getting started with [AstroNvim](https://github.com/AstroNvim/AstroNvim)

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

## ⌨️ Keybindings

### Save
| Keybinding | Action |
|-----------|--------|
| `<leader>s` | Save buffer |

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

### Other Keybindings
| Keybinding | Mode | Action |
|-----------|------|--------|
| `gw` | Normal, Visual | Enter window mode (access vim's `<C-w>` commands) |
| `<A-w>` | Normal | Switch to next window |
| `gh` | Normal, Visual | Go to beginning of line |
| `gl` | Normal, Visual | Go to end of line |
| `U` | Normal | Redo (opposite of `u`) |
| `jk`, `kj`, `jj` | Insert | Exit insert mode |
| `<C-a>` | Normal | Select all |
| `gV` | Normal | Select all |
| `<C-c>` | Normal, Visual | Comment line(s) |
| `<C-S>` | Normal, Insert, Visual, Select | (Default: save via Vim) |
