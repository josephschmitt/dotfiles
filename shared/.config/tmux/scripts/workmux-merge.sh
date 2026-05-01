#!/bin/sh
# workmux-merge - Interactive merge popup with strategy selection
set -eu

# Read default merge strategy from workmux config
CONFIG="$HOME/.config/workmux/config.yaml"
DEFAULT_STRATEGY="merge"
if [ -f "$CONFIG" ]; then
  parsed=$(grep '^merge_strategy:' "$CONFIG" | awk '{print $2}' | tr -d '[:space:]')
  [ -n "$parsed" ] && DEFAULT_STRATEGY="$parsed"
fi

# Step 1: Pick target branch (optional, defaults to main branch)
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||' || true)
BRANCHES=$(git branch --format='%(refname:short)' 2>/dev/null)
TARGET=$(printf '%s\n' "$BRANCHES" | gum filter --header "Merge into branch" --placeholder "default branch" --no-strict --value "$DEFAULT_BRANCH") || exit 0

# Step 2: Choose merge strategy
STRATEGY=$(gum choose --header "Merge strategy" --selected "$DEFAULT_STRATEGY" merge rebase squash) || exit 0

# Build command
CMD="workmux merge"
case "$STRATEGY" in
  rebase) CMD="$CMD --rebase" ;;
  squash) CMD="$CMD --squash" ;;
esac
[ -n "$TARGET" ] && CMD="$CMD --into $TARGET"

if ! eval "$CMD"; then
  echo ""
  gum style --faint "Press any key to close..."
  read -r _ || true
fi
