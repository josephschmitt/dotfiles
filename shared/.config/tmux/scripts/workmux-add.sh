#!/bin/sh
# workmux-add - Prompt for branch name and create a worktree
set -e

BRANCH=$(gum input --header "Branch name" --prompt "> ") || exit 0
[ -z "$BRANCH" ] && exit 1

exec workmux add "$BRANCH"
