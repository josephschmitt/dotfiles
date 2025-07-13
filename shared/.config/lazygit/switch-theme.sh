#!/bin/bash

CONFIG_DIR="$HOME/.config/lazygit"
CONFIG_FILE="$CONFIG_DIR/config.yml"

if [ $# -eq 0 ]; then
    echo "Available themes:"
    echo "  catppuccin"
    echo "  tokyonight"
    echo ""
    echo "Usage: $0 <theme-name>"
    echo "Example: $0 tokyonight"
    exit 1
fi

THEME="$1"
THEME_CONFIG="$CONFIG_DIR/config-$THEME.yml"

if [ ! -f "$THEME_CONFIG" ]; then
    echo "Theme '$THEME' not found"
    echo "Available themes: catppuccin, tokyonight"
    exit 1
fi

# Copy theme config
cp "$THEME_CONFIG" "$CONFIG_FILE"

echo "Switched to $THEME theme"