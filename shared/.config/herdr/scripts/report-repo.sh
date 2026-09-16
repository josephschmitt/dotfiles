#!/bin/sh
# Report the git repo basename as a $repo metadata token to herdr.
# Called from Claude Code SessionStart hooks.
set -eu

[ "${HERDR_ENV:-}" = "1" ] || exit 0
[ -n "${HERDR_SOCKET_PATH:-}" ] || exit 0
[ -n "${HERDR_PANE_ID:-}" ] || exit 0

# Use --git-common-dir so worktrees resolve to the main repo root, not the worktree path.
git_common_dir="$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" || exit 0
repo_name="$(basename "$(dirname "$git_common_dir")")"

branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)" || branch=""

herdr pane report-metadata "$HERDR_PANE_ID" \
  --source "dotfiles:repo" \
  --token "repo=$repo_name" \
  --token "branch=$branch"
