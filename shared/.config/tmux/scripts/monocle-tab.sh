#!/bin/sh
# Toggle a dedicated monocle tab
# If already on the monocle window, switch to the last window.
# If the monocle window exists, switch to it.
# Otherwise, create a new monocle window.

WINDOW_NAME="monocle"
CURRENT_WINDOW=$(tmux display-message -p '#{window_name}')

if [ "$CURRENT_WINDOW" = "$WINDOW_NAME" ]; then
  tmux last-window
elif tmux list-windows -F '#{window_name}' | grep -qx "$WINDOW_NAME"; then
  tmux select-window -t "$WINDOW_NAME"
else
  PANE_PATH=$(tmux display-message -p '#{pane_current_path}')
  tmux new-window -n "$WINDOW_NAME" -c "$PANE_PATH" "monocle"
fi
