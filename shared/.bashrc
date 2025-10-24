# Bash interactive shell configuration
# This file is sourced for interactive bash sessions

# Source shared aliases and functions
if [ -f "$HOME/.config/shell/aliases.sh" ]; then
  . "$HOME/.config/shell/aliases.sh"
fi

if [ -f "$HOME/.config/shell/functions.sh" ]; then
  . "$HOME/.config/shell/functions.sh"
fi

# Auto-source profile-specific aliases (aliases.*.sh)
for config_file in "$HOME/.config/shell/aliases."*.sh; do
  # Skip if glob didn't match any files (contains literal *)
  case "$config_file" in
    *"*"*) continue ;;
  esac
  if [ -f "$config_file" ]; then
    . "$config_file"
  fi
done

# Auto-source profile-specific functions (functions.*.sh)
for config_file in "$HOME/.config/shell/functions."*.sh; do
  # Skip if glob didn't match any files (contains literal *)
  case "$config_file" in
    *"*"*) continue ;;
  esac
  if [ -f "$config_file" ]; then
    . "$config_file"
  fi
done

# Load interactive customizations first (before tmux auto-start)
# Only skip if we're inside tmux AND already loaded
if [ -z "$TMUX" ] || [ -z "$TMUX_INTERACTIVE_LOADED" ]; then
  start_interactive
fi

# Auto-start tmux if available
auto_start_tmux

# TWM shell completions (lazy-loaded)
twm() {
  unset -f twm
  eval "$(command twm --print-bash-completion)"
  command twm "$@"
}
