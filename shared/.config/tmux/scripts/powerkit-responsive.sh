#!/usr/bin/env bash
# Width-aware powerkit plugin configuration
# Called by: client-resized hook
# Progressively hides status bar plugins as terminal narrows
# Hide order: datetime → hostname → directory+git → session

set -uo pipefail

# Get current terminal width
WIDTH=$(tmux display-message -p '#{client_width}' 2>/dev/null) || exit 0
[[ -z "$WIDTH" ]] && exit 0

# Breakpoints (configurable via tmux options)
BP_FULL=$(tmux show-option -gqv @powerkit_bp_full 2>/dev/null); BP_FULL="${BP_FULL:-130}"
BP_NO_DT=$(tmux show-option -gqv @powerkit_bp_no_datetime 2>/dev/null); BP_NO_DT="${BP_NO_DT:-100}"
BP_NO_HOST=$(tmux show-option -gqv @powerkit_bp_no_hostname 2>/dev/null); BP_NO_HOST="${BP_NO_HOST:-80}"

# External plugin definition (directory display)
EXT='external("󰉋"|"#{b:pane_current_path}"|"#fab387"|"#fcc9a3"|"0")'

# Determine target plugin set based on width
if (( WIDTH >= BP_FULL )); then
  target_plugins="hostname,${EXT},git,datetime"
elif (( WIDTH >= BP_NO_DT )); then
  target_plugins="hostname,${EXT},git"
elif (( WIDTH >= BP_NO_HOST )); then
  target_plugins="${EXT},git"
else
  target_plugins=""
fi

# Check if anything changed (avoid unnecessary cache clears)
current_plugins=$(tmux show-option -gqv @powerkit_plugins 2>/dev/null)
[[ "$current_plugins" == "$target_plugins" ]] && exit 0

# Apply new plugin configuration
tmux set-option -g @powerkit_plugins "$target_plugins"

# Clear render cache so powerkit picks up new plugin list
rm -f "${XDG_CACHE_HOME:-$HOME/.cache}/tmux-powerkit/data/rendered_"* 2>/dev/null
