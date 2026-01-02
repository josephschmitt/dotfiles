#!/bin/sh

temp_session="$1"

# Launch television sesh picker in a popup
# tv sesh handles session switching internally, so we just check if user made a selection
if "$TMUX_CONFIG_DIR/tmux-popup" -s small -t 'Sesh' -E "tv sesh"; then
  # User selected a session (exit code 0), kill the temporary session
  tmux kill-session -t "$temp_session"
fi

# If user cancelled (non-zero exit), stay in the temporary session
