#!/bin/sh
# Kill current tmux session. If it's the last session, just kill it and let
# the session-closed hook create a new "main" session. Otherwise, also close
# the terminal tab.

session_name=$(tmux display-message -p '#S')
client_pid=$(tmux display-message -p '#{client_pid}')
session_count=$(tmux list-sessions 2>/dev/null | wc -l | tr -d ' ')

# Kill the session
tmux kill-session -t "$session_name"

# Only close the terminal tab if there were other sessions to fall back to.
# When it was the last session, the session-closed hook creates "main" and
# detach-on-destroy switches the client to it — so we stay in tmux.
if [ "$session_count" -gt 1 ]; then
    if [ -n "$client_pid" ]; then
        parent_pid=$(ps -o ppid= -p "$client_pid" | tr -d ' ')
        if [ -n "$parent_pid" ]; then
            kill "$parent_pid"
        fi
    fi
fi
