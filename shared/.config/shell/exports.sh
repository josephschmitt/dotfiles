# Shared environment variables for all POSIX-compatible shells
# This file should contain only environment variable exports

# XDG Base Directory Specification
export XDG_CONFIG_HOME="$HOME/.config"

# Default editor
export EDITOR="nvim"

# OpenAI API Key (using 1Password CLI)
export OPENAI_API_KEY="op://Private/OPENAI_API_KEY/credential"

# Zellij configuration
export ZJ_ALWAYS_NAME="true"
export ZJ_DEFAULT_LAYOUT="ide"
export ZJ_LAYOUTS_DIR="$HOME/development/zj/layouts"

# PATH Configuration
# Add custom bin directories
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/development/zide/bin:$PATH"
export PATH="$HOME/development/zj/bin:$PATH"

# Package managers and version managers
export PATH="/opt/homebrew/bin:$PATH"

# ASDF version manager
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# Volta Node.js version manager
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# Source personal environment file if it exists
if [ -f "$HOME/.env" ]; then
  . "$HOME/.env"
fi