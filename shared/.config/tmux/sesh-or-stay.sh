#!/bin/sh

temp_session="$1"

selected=$(tv sesh)

if [ -n "$selected" ]; then
  sesh connect "$selected"
  tmux kill-session -t "$temp_session"
fi
