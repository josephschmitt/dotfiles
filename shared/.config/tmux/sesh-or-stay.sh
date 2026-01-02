#!/bin/sh

temp_session="$1"

# Get current session before launching popup
current_session=$(tmux display-message -p '#S')

# Launch television sesh picker in a popup
# tv sesh handles session switching internally
"$TMUX_CONFIG_DIR/tmux-popup" -s small -t 'Sesh' -E "tv sesh"

# Check if we're still in the temp session
new_session=$(tmux display-message -p '#S')

# Only kill temp session if we switched to a different session
if [ "$new_session" != "$temp_session" ]; then
  # User selected a session and switched, kill the temporary session
  tmux kill-session -t "$temp_session"
fi

# If we're still in temp session (user cancelled), keep it
