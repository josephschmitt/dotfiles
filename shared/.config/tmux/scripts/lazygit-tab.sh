#!/bin/sh
# Toggle a dedicated lazygit tab
# If already on the lazygit window, switch to the last window.
# If the lazygit window exists, switch to it.
# Otherwise, create a new lazygit window.

WINDOW_NAME="lazygit"
CURRENT_WINDOW=$(tmux display-message -p '#{window_name}')

if [ "$CURRENT_WINDOW" = "$WINDOW_NAME" ]; then
  tmux last-window
elif tmux list-windows -F '#{window_name}' | grep -qx "$WINDOW_NAME"; then
  tmux select-window -t "$WINDOW_NAME"
else
  PANE_PATH=$(tmux display-message -p '#{pane_current_path}')
  LG_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/lazygit"
  LG_CONFIGS="$LG_CONFIG_DIR/config.yml,$LG_CONFIG_DIR/config-tab.yml"
  if [ -f "$LG_CONFIG_DIR/config-work.yml" ]; then
    LG_CONFIGS="$LG_CONFIGS,$LG_CONFIG_DIR/config-work.yml"
  fi
  tmux new-window -n "$WINDOW_NAME" -c "$PANE_PATH" "lazygit --use-config-file=$LG_CONFIGS"
fi
