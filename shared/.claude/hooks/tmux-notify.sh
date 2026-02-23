#!/bin/bash
# Wrap Claude Code notifications in tmux DCS passthrough sequence
# Only activates when running inside tmux - otherwise exits silently

[ -z "$TMUX" ] && exit 0

read -r input
message=$(echo "$input" | jq -r '.message // "Claude Code"')

# Output to /dev/tty since hook stdout is captured by Claude Code
printf '\ePtmux;\e\e]9;%s\e\e\\\e\\' "$message" > /dev/tty
