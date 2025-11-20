# Shared environment variables for all POSIX-compatible shells
# This file should contain only environment variable exports

# XDG Base Directory Specification
export XDG_CONFIG_HOME="$HOME/.config"

# Default editor
export EDITOR="nvim"

export COLORTERM="truecolor"
export BAT_THEME="tokyonight_night"

# Eza configuration
export EZA_ICONS_AUTO="always"
export EZA_CONFIG_DIR="$XDG_CONFIG_HOME/eza"

# Zellij configuration
export ZJ_ALWAYS_NAME="true"
export ZJ_DEFAULT_LAYOUT="ide"
export ZJ_LAYOUTS_DIR="$HOME/development/zj/layouts"

# Zellij/Zide configuration
export ZELLIJ_CONFIG_DIR="$HOME/.config/zellij"
export ZIDE_DEFAULT_LAYOUT="compact_lazygit_focus"
export ZIDE_LAYOUT_DIR="$ZELLIJ_CONFIG_DIR/layouts/zide"
export ZIDE_ALWAYS_NAME="true"
export ZIDE_USE_YAZI_CONFIG="false"
export ZIDE_USE_FOCUS_PLUGIN="true"

# FZF configuration
# fd respects .ignore files automatically, just exclude .git
export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude=.git"

# PATH Configuration
# Nix paths (set first to resolve before other paths like homebrew)
export PATH="$HOME/.nix-profile/bin:$PATH"
export PATH="/run/current-system/sw/bin:$PATH"
export PATH="/nix/var/nix/profiles/default/bin:$PATH"

# Package managers and version managers
export PATH="/opt/homebrew/bin:$PATH"
export PATH="$HOME/.bun/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

# Custom bin directories
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/development/zide/bin:$PATH"
export PATH="$HOME/development/zj/bin:$PATH"

# PNPM package manager
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Application paths (appended to end of PATH)
export PATH="$PATH:$HOME/.opencode/bin"
export PATH="$PATH:$HOME/.lmstudio/bin"
export PATH="$PATH:$HOME/.antigravity/antigravity/bin"

# Homebrew configuration
export HOMEBREW_NO_ENV_HINTS=1

# Source personal environment file if it exists
if [ -f "$HOME/.env" ]; then
  . "$HOME/.env"
fi

if [ "$TERM_PROGRAM" = "ghostty" ]; then
  export TERM=xterm-256color
fi
