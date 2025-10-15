#!/bin/sh

temp_session="$1"

selected=$(~/.config/tmux/sesh-popup.sh)

if [ -n "$selected" ]; then
  sesh connect "$selected"
  tmux kill-session -t "$temp_session"
fi
