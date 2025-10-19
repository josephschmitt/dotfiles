# POSIX-compliant profile for environment variables
# This file is sourced by login shells and should contain only environment setup
# It should work with sh, bash, zsh, and other POSIX-compatible shells

# Source shared environment variables
if [ -f "$HOME/.config/shell/exports.sh" ]; then
  . "$HOME/.config/shell/exports.sh"
fi

# Auto-source profile-specific environment variables (exports.*.sh)
# Handle zsh differently due to different glob behavior
if [ -n "$ZSH_VERSION" ]; then
  # Zsh: temporarily enable nullglob
  setopt nullglob 2>/dev/null || true
  for config_file in "$HOME/.config/shell/exports."*.sh; do
    if [ -f "$config_file" ]; then
      . "$config_file"
    fi
  done
  unsetopt nullglob 2>/dev/null || true
else
  # POSIX shells: use case statement to skip unmatched globs
  for config_file in "$HOME/.config/shell/exports."*.sh; do
    case "$config_file" in
      *"*"*) continue ;;
    esac
    if [ -f "$config_file" ]; then
      . "$config_file"
    fi
  done
fi

# OrbStack integration (macOS)
if [ -f ~/.orbstack/shell/init.sh ]; then
  . ~/.orbstack/shell/init.sh 2>/dev/null || :
fi