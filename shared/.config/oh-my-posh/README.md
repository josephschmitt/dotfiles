# Oh My Posh Configuration

Configuration for [Oh My Posh](https://ohmyposh.dev) - a cross-platform, cross-shell prompt theme engine for a beautiful and informative command-line prompt.

## Features

- **Consistent prompts** across all shells (Fish, Zsh, Bash)
- **Git integration** - Shows branch, status, and changes
- **Custom segments** - Shell type, OS, path, SSH session info
- **Icon support** - Uses Nerd Font icons throughout
- **Custom color palette** - Coordinated theming

## File Structure

- `themes/custom.omp.yaml` - Custom prompt theme configuration

## Prompt Segments

The prompt displays the following information (left to right):

1. **OS icon** - Visual indicator of operating system
2. **Shell name** - Current shell (fish, zsh, bash)
3. **SSH session** - Shows `user@host` when connected via SSH
4. **Current path** - Directory path with custom icons
   - Home directory shows house icon (```)
   - Development folder shows code icon (```)
   - Uses "agnoster_short" style for compact display
5. **Git status** - When in a git repository:
   - Branch name with icon
   - Working changes (unstaged)
   - Staged changes
   - Upstream status

## Color Palette

Custom colors defined for consistent theming:
- **Blue** (`#8CAAEE`) - Session/user info
- **Pink** (`#F4B8E4`) - Path
- **Lavender** (`#BABBF1`) - Git status
- **OS** (`#ACB0BE`) - OS and shell indicators

## Git Integration

Displays rich git information:
- Branch icon (```) with current branch name
- Working tree changes with file count
- Staged changes with file count
- Fetch status and upstream tracking
- Special icons for cherry-pick, merge, rebase operations

## Shell Integration

Oh My Posh is initialized in each shell's configuration:

**Fish** (`config.fish`):
```fish
oh-my-posh init fish --config ~/.config/oh-my-posh/themes/custom.omp.yaml | source
```

**Zsh** (`.zshrc`):
```zsh
eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/themes/custom.omp.yaml)"
```

**Bash** (`.bashrc`):
```bash
eval "$(oh-my-posh init bash --config ~/.config/oh-my-posh/themes/custom.omp.yaml)"
```

## Installation

Installed via main dotfiles setup:

```bash
stow shared
```

## Dependencies

- **oh-my-posh** - The prompt engine
- **Nerd Font** - For icon display (Monaco Nerd Font Mono recommended)

## Customization

Edit `custom.omp.yaml` to modify:
- Color palette
- Segment order and visibility
- Icons and formatting
- Git display options
- Path display style

Reload the shell after changes to see updates.

## Benefits

- **Maintainability** - Single YAML config vs. complex shell-specific code
- **Consistency** - Same prompt across all shells
- **Portability** - Works on macOS, Linux, Windows
- **Declarative** - Easy to understand and modify
