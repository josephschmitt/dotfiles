#!/bin/sh
# workmux-add - Prompt for branch name and create a worktree
set -e

BRANCH=$(gum input --header "Branch name" --prompt "> ") || exit 0
[ -z "$BRANCH" ] && exit 1

if ! workmux add "$BRANCH"; then
  echo ""
  gum style --faint "Press any key to close..."
  read -r _ || true
fi
