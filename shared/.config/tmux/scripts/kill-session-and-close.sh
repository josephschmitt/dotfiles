#!/bin/sh
# Kill the current tmux session AND close the terminal tab. If this was the
# last session, the session-closed hook recreates a background "main" for
# next time — but the current tab closes either way.

session_name=$(tmux display-message -p '#S')
client_pid=$(tmux display-message -p '#{client_pid}')

tmux kill-session -t "$session_name"

if [ -n "$client_pid" ]; then
    parent_pid=$(ps -o ppid= -p "$client_pid" | tr -d ' ')
    if [ -n "$parent_pid" ]; then
        kill "$parent_pid"
    fi
fi
