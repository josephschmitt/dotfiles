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
BRANCH=$(printf '%s\n' "$BRANCHES" | gum filter --header "$HEADER" --placeholder "current worktree" --no-strict) || exit 0

if [ -n "$BRANCH" ]; then
  exec workmux remove $FORCE "$BRANCH"
else
  exec workmux remove $FORCE
fi
