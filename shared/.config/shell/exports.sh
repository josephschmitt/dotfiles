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
export ZELLIJ_CONFIG_DIR="$HOME/.config/zellij"

# Zide configuration
export ZIDE_DEFAULT_LAYOUT="compact_lazygit_focus"
export ZIDE_LAYOUT_DIR="$ZELLIJ_CONFIG_DIR/layouts/zide"
export ZIDE_ALWAYS_NAME="true"
export ZIDE_DEFAULT_LAYOUT="default_lazygit"
export ZIDE_USE_YAZI_CONFIG="false"
export ZIDE_USE_FOCUS_PLUGIN="true"

# Fuzzy finder configuration
# fd respects .ignore files automatically, just exclude .git
export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude=.git"

# PATH Configuration
# Nix paths (set first to resolve before other paths like homebrew)
export PATH="$HOME/.nix-profile/bin:$PATH"
export PATH="/run/current-system/sw/bin:$PATH"
export PATH="/nix/var/nix/profiles/default/bin:$PATH"

# Homebrew configuration
export HOMEBREW_NO_ENV_HINTS=1

# Package managers and version managers
export PATH="/opt/homebrew/bin:$PATH"
export PATH="$HOME/.bun/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

# Volta Node.js version manager
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# Custom bin directories
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/development/zide/bin:$PATH"
export PATH="$HOME/development/zj/bin:$PATH"

# ASDF version manager
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# PNPM package manager
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Source personal environment file if it exists
if [ -f "$HOME/.env" ]; then
  . "$HOME/.env"
fi

if [ "$TERM_PROGRAM" = "ghostty" ]; then
  export TERM=xterm-256color
fi

# Added by LM Studio CLI (lms)
export PATH="$PATH:$HOME/.lmstudio/bin"
# End of LM Studio CLI section
