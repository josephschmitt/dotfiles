#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract values using jq
MODEL_DISPLAY=$(echo "$input" | jq -r '.model.display_name')
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir')

# Extract context window information
CONTEXT_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
CURRENT_USAGE=$(echo "$input" | jq '.context_window.current_usage // empty')

# Calculate context percentage if data is available
CONTEXT_PERCENT=""
if [ -n "$CONTEXT_SIZE" ] && [ "$CURRENT_USAGE" != "" ] && [ "$CURRENT_USAGE" != "null" ]; then
  INPUT_TOKENS=$(echo "$CURRENT_USAGE" | jq -r '.input_tokens // 0')
  CACHE_CREATION=$(echo "$CURRENT_USAGE" | jq -r '.cache_creation_input_tokens // 0')
  CACHE_READ=$(echo "$CURRENT_USAGE" | jq -r '.cache_read_input_tokens // 0')

  TOTAL_USED=$((INPUT_TOKENS + CACHE_CREATION + CACHE_READ))
  PERCENT=$((TOTAL_USED * 100 / CONTEXT_SIZE))

  # Color code based on percentage
  if [ "$PERCENT" -le 50 ]; then
    # Green for safe usage
    CONTEXT_PERCENT=" \033[32m🧠 ${PERCENT}%\033[0m"
  elif [ "$PERCENT" -le 75 ]; then
    # Yellow for moderate usage
    CONTEXT_PERCENT=" \033[33m🧠 ${PERCENT}%\033[0m"
  else
    # Red for high usage
    CONTEXT_PERCENT=" \033[31m🧠 ${PERCENT}%\033[0m"
  fi
fi

# Determine directory name - show relative to git root if in a subdirectory
if git -C "$CURRENT_DIR" rev-parse --git-dir >/dev/null 2>&1; then
  # We're in a git repo
  REL_PATH=$(git -C "$CURRENT_DIR" rev-parse --show-prefix 2>/dev/null)
  # Remove trailing slash if present
  REL_PATH=${REL_PATH%/}

  if [ -z "$REL_PATH" ]; then
    # At git root, use basename
    DIR_NAME=$(basename "$CURRENT_DIR")
  else
    # In a subdirectory, use relative path
    DIR_NAME="$REL_PATH"
  fi
else
  # Not in a git repo, use basename
  DIR_NAME=$(basename "$CURRENT_DIR")
fi

# Show git branch if in a git repo
GIT_BRANCH=""
if git -C "$CURRENT_DIR" rev-parse --git-dir >/dev/null 2>&1; then
  BRANCH=$(git -C "$CURRENT_DIR" branch --show-current 2>/dev/null)
  if [ -n "$BRANCH" ]; then
    # Use ANSI color codes: green for branch name
    GIT_BRANCH=" \033[32m🌿 $BRANCH\033[0m"
  fi
fi

# Output format: [Model] [percentage] 📁 directory  branch
# Use ANSI color codes: cyan for model, white for directory, green for branch
echo -e "\033[36m🤖 $MODEL_DISPLAY\033[0m$CONTEXT_PERCENT \033[37m📁 $DIR_NAME\033[0m$GIT_BRANCH"
