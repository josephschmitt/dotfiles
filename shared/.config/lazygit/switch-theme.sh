#!/bin/bash

CONFIG_DIR="$HOME/.config/lazygit"
CONFIG_FILE="$CONFIG_DIR/config.yml"

# Get available themes by looking for config-*.yml files
AVAILABLE_THEMES=($(ls "$CONFIG_DIR"/config-*.yml 2>/dev/null | sed 's/.*config-\(.*\)\.yml/\1/'))

if [ ${#AVAILABLE_THEMES[@]} -eq 0 ]; then
    echo "No themes found in $CONFIG_DIR"
    exit 1
fi

# If no theme provided, use gum to choose (fallback to simple list)
if [ $# -eq 0 ]; then
    if command -v gum &> /dev/null; then
        THEME=$(printf '%s\n' "${AVAILABLE_THEMES[@]}" | gum choose --header "Choose a lazygit theme:")
        if [ -z "$THEME" ]; then
            echo "No theme selected"
            exit 0
        fi
    else
        echo "Available themes:"
        printf '  %s\n' "${AVAILABLE_THEMES[@]}"
        echo ""
        echo "Usage: $0 <theme-name>"
        echo "Example: $0 ${AVAILABLE_THEMES[0]}"
        echo ""
        echo "Tip: Install gum for interactive theme selection: brew install gum"
        exit 1
    fi
else
    THEME="$1"
fi

THEME_CONFIG="$CONFIG_DIR/config-$THEME.yml"

if [ ! -f "$THEME_CONFIG" ]; then
    echo "Theme '$THEME' not found"
    echo "Available themes: ${AVAILABLE_THEMES[*]}"
    exit 1
fi

# Copy theme config
cp "$THEME_CONFIG" "$CONFIG_FILE"

echo "Switched to $THEME theme"