# ~/.config/tmux/tmux.conf

## Install

### 1. Ensure proper Stow setup
Before installing tmux plugins, make sure the `~/.config/tmux` directory exists so Stow doesn't symlink the entire directory:

```bash
mkdir -p ~/.config/tmux
```

**Why this matters:**
- Stow symlinks entire directories if they don't exist at the target location
- If Stow symlinks the entire `~/.config/tmux/` directory, the `plugins/` subdirectory will also be symlinked
- TPM needs to create and manage `~/.config/tmux/plugins/` as a real directory, not a symlink
- Creating `~/.config/tmux` first forces Stow to symlink individual files (like `tmux.conf`) instead

### 2. Install TPM (Tmux Plugin Manager)
```bash
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
```

### 3. Install plugins
Inside tmux, press: `Ctrl+I`
