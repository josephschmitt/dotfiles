# Lazygit Configuration

This directory contains lazygit configuration with support for multiple themes.

## Features

- **Custom GitHub command**: Press `G` to open the current repository in GitHub
- **Multiple themes**: Easy switching between color schemes
- **Theme preservation**: All settings are preserved when switching themes

## Theme Management

### Available Themes

- **tokyonight**: Tokyo Night theme matching LazyVim
- **catppuccin**: Catppuccin Mocha theme

### Switching Themes

**Interactive theme selection (with gum):**
```bash
~/.config/lazygit/switch-theme.sh
```

**Switch to a specific theme:**
```bash
~/.config/lazygit/switch-theme.sh tokyonight
~/.config/lazygit/switch-theme.sh catppuccin
```

**Install gum for better UX:**
```bash
brew install gum
```

### Adding New Themes

1. Create a complete config file for your theme:
   ```bash
   cp ~/.config/lazygit/config-catppuccin.yml ~/.config/lazygit/config-mytheme.yml
   ```

2. Edit the theme colors in the new file:
   ```bash
   # Edit the gui.theme section in config-mytheme.yml
   ```

3. Switch to your new theme:
   ```bash
   ~/.config/lazygit/switch-theme.sh mytheme
   ```

### Shell Alias (Optional)

Add this to your shell config for easier theme switching:
```bash
alias lgtheme='~/.config/lazygit/switch-theme.sh'
```

Then use: `lgtheme tokyonight` or `lgtheme catppuccin`

## File Structure

```
~/.config/lazygit/
├── config.yml              # Main configuration file
├── config-catppuccin.yml   # Catppuccin theme config
├── config-tokyonight.yml   # Tokyo Night theme config
├── switch-theme.sh         # Theme switcher script
└── README.md               # This file
```

## Custom Commands

### Keybindings

- **`G`** (global): Open current repository in GitHub (works with both SSH and HTTPS remotes)
- **`c`** (in files view): Smart commit workflow with default branch protection
  - Automatically detects the default branch by:
    1. Checking `origin/HEAD` (the remote's default branch)
    2. Falling back to checking for `main` or `master` branches locally
  - Shows a menu with options when you're on the default branch:
    - **Create new branch first**: Prompts for branch name, creates it, switches to it
    - **Commit to current branch**: Dismisses menu so you can use `C` to commit
    - **Cancel**: (automatically added by lazygit) Cancels the operation
  - Displays current branch name in the menu so you always know where you are
  - Perfect for repos where only PRs should merge to the default branch
- **`C`** (Shift+c, in files view): Direct commit (bypasses branch check)
  - Prompts for commit message and commits immediately
  - Use this when you're certain you want to commit to the current branch

### Usage Tips

- **`c`** is your default commit key - it will always show you what branch you're on and give you options
- After creating a new branch with `c` → "Create new branch first", press `C` to commit directly
- Use `C` (Shift+c) only when you're certain you want to commit to the current branch without any checks

### Adding Custom Commands

When adding new custom commands to `config.yml`, always include `shell: sh` to ensure they work regardless of your default shell (especially if using Fish):

```yaml
customCommands:
  - key: "X"
    context: "files"
    description: "My custom command"
    shell: sh  # ← Important for Fish shell compatibility
    command: |
      # Your POSIX-compliant shell script here
```

This ensures commands use a POSIX shell (`/bin/sh`) instead of Fish, which has different syntax.

## Version Control

Since this is a git-managed dotfiles repository, all theme changes are tracked in version history - no backup files needed.