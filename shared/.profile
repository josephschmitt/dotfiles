# POSIX-compliant profile for environment variables
# This file is sourced by login shells and should contain only environment setup
# It should work with sh, bash, zsh, and other POSIX-compatible shells

# Source shared environment variables
if [ -f "$HOME/.config/shell/exports.sh" ]; then
  . "$HOME/.config/shell/exports.sh"
fi

# Auto-source profile-specific environment variables (exports.*.sh)
for config_file in "$HOME/.config/shell/exports."*.sh; do
  if [ -f "$config_file" ]; then
    . "$config_file"
  fi
done

# OrbStack integration (macOS)
if [ -f ~/.orbstack/shell/init.sh ]; then
  . ~/.orbstack/shell/init.sh 2>/dev/null || :
fi