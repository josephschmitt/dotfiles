#!/bin/sh
# Kill current tmux session and close the terminal tab

# Get the current session name
session_name=$(tmux display-message -p '#S')

# Get the client PID (the tmux client process)
client_pid=$(tmux display-message -p '#{client_pid}')

# Kill the session
tmux kill-session -t "$session_name"

# Find and kill the parent shell that launched tmux (closes the terminal tab)
# The parent of the tmux client is typically the shell
if [ -n "$client_pid" ]; then
    parent_pid=$(ps -o ppid= -p "$client_pid" | tr -d ' ')
    if [ -n "$parent_pid" ]; then
        kill "$parent_pid"
    fi
fi
