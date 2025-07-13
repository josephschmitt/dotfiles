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

- **`G`**: Open current repository in GitHub (works with both SSH and HTTPS remotes)

## Version Control

Since this is a git-managed dotfiles repository, all theme changes are tracked in version history - no backup files needed.