#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract values using jq
MODEL_DISPLAY=$(echo "$input" | jq -r '.model.display_name')
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir')

# Get basename of current directory
DIR_NAME=$(basename "$CURRENT_DIR")

# Show git branch if in a git repo
GIT_BRANCH=""
if [ -d "$CURRENT_DIR/.git" ] || git -C "$CURRENT_DIR" rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git -C "$CURRENT_DIR" branch --show-current 2>/dev/null)
    if [ -n "$BRANCH" ]; then
        # Use ANSI color codes: green for branch name
        GIT_BRANCH=" \033[32m\033[0m $BRANCH"
    fi
fi

# Output format: [Model] 📁 directory  branch
# Use ANSI color codes: cyan for model, yellow for directory
echo -e "\033[36m[$MODEL_DISPLAY]\033[0m \033[33m📁 $DIR_NAME\033[0m$GIT_BRANCH"
