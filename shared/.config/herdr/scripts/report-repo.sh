#!/bin/sh
# Report the git repo basename as a $repo metadata token to herdr.
# Called from Claude Code SessionStart hooks.
set -eu

[ "${HERDR_ENV:-}" = "1" ] || exit 0
[ -n "${HERDR_SOCKET_PATH:-}" ] || exit 0
[ -n "${HERDR_PANE_ID:-}" ] || exit 0

repo_root="$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0
repo_name="$(basename "$repo_root")"

herdr pane report-metadata "$HERDR_PANE_ID" \
  --source "dotfiles:repo" \
  --token "repo=$repo_name"
