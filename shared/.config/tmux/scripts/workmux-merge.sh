#!/bin/sh
# workmux-merge - Interactive merge popup with strategy selection
set -e

# Read default merge strategy from workmux config
CONFIG="$HOME/.config/workmux/config.yaml"
DEFAULT_STRATEGY="merge"
if [ -f "$CONFIG" ]; then
  parsed=$(grep '^merge_strategy:' "$CONFIG" | awk '{print $2}' | tr -d '[:space:]')
  [ -n "$parsed" ] && DEFAULT_STRATEGY="$parsed"
fi

# Step 1: Choose merge strategy
STRATEGY=$(gum choose --header "Merge strategy" --selected "$DEFAULT_STRATEGY" merge rebase squash) || exit 0

# Step 2: Input target branch (optional)
TARGET=$(gum input --header "Merge into branch" --placeholder "default branch") || exit 0

# Build command
CMD="workmux merge"
case "$STRATEGY" in
  rebase) CMD="$CMD --rebase" ;;
  squash) CMD="$CMD --squash" ;;
esac
[ -n "$TARGET" ] && CMD="$CMD --into $TARGET"

exec sh -c "$CMD"
