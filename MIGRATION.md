# Migration Guide

## Overview

This repository has undergone a major restructure to use GNU Stow for symlink management with work/personal separation. **All existing symlinks from the previous structure will be broken** and need to be recreated.

## What Changed

### Previous Structure (Before e2f9f33)
```
dotfiles/
├── .config/
├── .gitconfig
├── .zshrc
└── ... (all config files in root)
```

### New Structure (After e2f9f33)
```
dotfiles/
├── shared/          # Common configurations for all machines
│   ├── .config/     # Application configurations
│   ├── .zshrc       # Shell configurations
│   └── ...
├── personal/        # Personal-specific configurations
│   └── .gitconfig   # Personal git settings
└── work/           # Work-specific configurations (private submodule)
    ├── .gitconfig   # Work git settings
    └── .compassrc   # Company-specific tools
```

## Migration Steps

### 1. Remove Old Symlinks

First, remove all existing symlinks that are now broken:

```bash
cd ~
# Remove broken symlinks (adjust paths as needed based on your setup)
find . -maxdepth 1 -type l -exec ls -la {} \; | grep dotfiles
# Manually remove each broken symlink, for example:
rm ~/.gitconfig ~/.zshrc ~/.tmux.conf
# Remove broken .config symlinks
find ~/.config -type l -exec ls -la {} \; | grep dotfiles
# Remove broken ones manually
```

### 2. Backup Existing Configs (Optional)

If you have any local modifications:

```bash
mkdir ~/dotfiles-backup-$(date +%Y%m%d)
# Move any existing configs you want to preserve
mv ~/.gitconfig ~/dotfiles-backup-$(date +%Y%m%d)/ 2>/dev/null || true
mv ~/.zshrc ~/dotfiles-backup-$(date +%Y%m%d)/ 2>/dev/null || true
```

### 3. Update Repository

```bash
cd ~/.dotfiles
git pull origin main
```

### 4. Install GNU Stow

If you don't have Stow installed:

```bash
# macOS
brew install stow

# Ubuntu/Debian
sudo apt install stow

# Arch Linux
sudo pacman -S stow
```

### 5. Apply New Configuration

#### For Personal Machines:
```bash
cd ~/.dotfiles
stow shared personal
```

#### For Work Machines:
```bash
cd ~/.dotfiles
# Initialize work submodule (requires access to private work repo)
git submodule update --init --recursive
stow shared work
```

### 6. Restart Shell

```bash
exec $SHELL
```

## Troubleshooting

### Stow Conflicts

If stow reports conflicts with existing files:

```bash
# Backup conflicting files
mkdir ~/dotfiles-backup
mv ~/.gitconfig ~/dotfiles-backup/  # repeat for each conflicting file

# Then retry stow
stow shared personal  # or work
```

### Finding Broken Symlinks

To find all broken symlinks in your home directory:

```bash
find ~ -type l -exec test ! -e {} \; -print 2>/dev/null
```

### Verifying New Setup

Check that symlinks are working correctly:

```bash
ls -la ~/.gitconfig ~/.zshrc ~/.config/fish/config.fish
```

You should see symlinks pointing to files in `~/.dotfiles/shared/` or `~/.dotfiles/personal/` (or `work/`).

## Key Benefits of New Structure

- **Clean separation** between work and personal configurations
- **Easy deployment** across different machine types
- **No complex templating** - files are files
- **Secure work configs** - sensitive data in private submodule
- **Simple maintenance** - standard GNU Stow workflow

## Need Help?

If you encounter issues during migration:

1. Check the [main README](README.md) for detailed setup instructions
2. Review the [shared README](shared/README.md) for troubleshooting tips
3. Ensure you have proper SSH access to GitHub repositories

## Rollback (Emergency)

If you need to quickly rollback to a working state:

```bash
cd ~/.dotfiles
# Remove new symlinks
stow -D shared personal  # or work

# Restore from backup
cp ~/dotfiles-backup/* ~/
```

Then you can work on fixing the migration issues.