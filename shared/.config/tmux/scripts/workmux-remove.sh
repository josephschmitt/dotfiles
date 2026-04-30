#!/bin/sh
# workmux-remove - Prompt for branch name and remove a worktree
set -e

FORCE=""
if [ "$1" = "--force" ]; then
  FORCE="--force"
fi

if [ -n "$FORCE" ]; then
  HEADER="Branch to force remove"
else
  HEADER="Branch to remove"
fi

BRANCHES=$(workmux ls 2>/dev/null | tail -n +2 | awk '{print $1}')
CURRENT=$(git branch --show-current 2>/dev/null || echo "")
BRANCH=$(printf '%s\n' "$BRANCHES" | gum filter --header "$HEADER" --value "$CURRENT" --placeholder "current worktree" --no-strict) || exit 0

if [ -n "$BRANCH" ]; then
  CMD="workmux remove $FORCE $BRANCH"
else
  CMD="workmux remove $FORCE"
fi

if ! ERROR=$(eval "$CMD" 2>&1); then
  gum style --foreground 1 --bold "ERROR"
  echo ""
  echo "$ERROR"
  echo ""
  gum style --faint "Press any key to close..."
  read -r _ || true
  exit 0
fi
