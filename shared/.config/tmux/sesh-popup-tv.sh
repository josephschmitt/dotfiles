#!/bin/sh
# Sesh session selector using television
# This script is designed to be run inside a tmux popup

sesh connect "$(tv sesh \
  --input-header "Session Manager" \
  --input-prompt "⚡ " \
  --no-remote \
  --hide-help-panel)"
