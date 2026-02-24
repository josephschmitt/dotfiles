#!/bin/bash
# Send terminal notifications (OSC 9) with tmux DCS passthrough support
# When in tmux, wraps the sequence so tmux forwards it to the outer terminal
# When not in tmux, sends the plain OSC 9 sequence

read -r input
message=$(echo "$input" | jq -r '.message // "Agent Notification"')

# Output to /dev/tty since hook stdout is captured
if [ -n "$TMUX" ]; then
  printf $'\ePtmux;\e\e]9;%s\e\e\\\e\\' "$message" > /dev/tty
else
  printf $'\e]9;%s\e\\' "$message" > /dev/tty
fi
