#!/bin/sh
# workmux-add - Prompt for branch name and create a worktree
set -e

BRANCH=$(gum input --header "Branch name" --prompt "> ") || exit 0
[ -z "$BRANCH" ] && exit 1

if ! ERROR=$(workmux add "$BRANCH" 2>&1); then
  gum style --foreground 1 --bold "ERROR"
  echo ""
  echo "$ERROR"
  echo ""
  gum style --faint "Press any key to close..."
  read -r _ || true
  exit 0
fi
