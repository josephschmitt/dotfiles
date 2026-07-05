#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract values using jq
MODEL_DISPLAY=$(echo "$input" | jq -r '.model.display_name')
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir')

# Check if we're in a git repo (cache this result for reuse)
IS_GIT_REPO=false
if git -C "$CURRENT_DIR" rev-parse --git-dir >/dev/null 2>&1; then
  IS_GIT_REPO=true
fi

# Extract rate limit information
FIVE_HOUR=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
FIVE_HOUR_RESETS=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
SEVEN_DAY=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# Extract context window information
CONTEXT_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 0 | tonumber? // 0')
CURRENT_USAGE=$(echo "$input" | jq '.context_window.current_usage // empty')

# Calculate context percentage if data is available
CONTEXT_PERCENT=""
if [ -n "$CONTEXT_SIZE" ] && [ "$CONTEXT_SIZE" -gt 0 ] && [ "$CURRENT_USAGE" != "" ] && [ "$CURRENT_USAGE" != "null" ]; then
  INPUT_TOKENS=$(echo "$CURRENT_USAGE" | jq -r '.input_tokens // 0 | tonumber? // 0')
  CACHE_CREATION=$(echo "$CURRENT_USAGE" | jq -r '.cache_creation_input_tokens // 0 | tonumber? // 0')
  CACHE_READ=$(echo "$CURRENT_USAGE" | jq -r '.cache_read_input_tokens // 0 | tonumber? // 0')

  TOTAL_USED=$(( ${INPUT_TOKENS:-0} + ${CACHE_CREATION:-0} + ${CACHE_READ:-0} ))
  PERCENT=$(( ${TOTAL_USED:-0} * 100 / ${CONTEXT_SIZE:-1} ))

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
if [ "$IS_GIT_REPO" = true ]; then
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
if [ "$IS_GIT_REPO" = true ]; then
  BRANCH=$(git -C "$CURRENT_DIR" branch --show-current 2>/dev/null)
  if [ -n "$BRANCH" ]; then
    # Use ANSI color codes: green for branch name
    GIT_BRANCH=" \033[32m🌿 $BRANCH\033[0m"
  fi
fi

# Show git diff stats (lines added/removed) if in a git repo
GIT_DIFF_STATS=""
if [ "$IS_GIT_REPO" = true ]; then
  TOTAL_ADDED=0
  TOTAL_DELETED=0

  # Sum unstaged and staged changes
  while IFS=$'\t' read -r added deleted _; do
    [[ "$added" =~ ^[0-9]+$ ]] && TOTAL_ADDED=$(( TOTAL_ADDED + added ))
    [[ "$deleted" =~ ^[0-9]+$ ]] && TOTAL_DELETED=$(( TOTAL_DELETED + deleted ))
  done < <(cat <(git -C "$CURRENT_DIR" diff --numstat 2>/dev/null) <(git -C "$CURRENT_DIR" diff --cached --numstat 2>/dev/null))

  if [ "$TOTAL_ADDED" -gt 0 ] || [ "$TOTAL_DELETED" -gt 0 ]; then
    DIFF_PARTS=""
    [ "$TOTAL_ADDED" -gt 0 ] && DIFF_PARTS="\033[32m+${TOTAL_ADDED}\033[0m"
    if [ "$TOTAL_DELETED" -gt 0 ]; then
      [ -n "$DIFF_PARTS" ] && DIFF_PARTS="$DIFF_PARTS "
      DIFF_PARTS="${DIFF_PARTS}\033[31m-${TOTAL_DELETED}\033[0m"
    fi
    GIT_DIFF_STATS=" $DIFF_PARTS"
  fi
fi

# Show commits ahead/behind remote if in a git repo
GIT_SYNC_STATUS=""
if [ "$IS_GIT_REPO" = true ]; then
  AHEAD_BEHIND=$(git -C "$CURRENT_DIR" rev-list --left-right --count 'HEAD...@{upstream}' 2>/dev/null)
  if [ -n "$AHEAD_BEHIND" ]; then
    AHEAD=$(echo "$AHEAD_BEHIND" | awk '{print $1}')
    BEHIND=$(echo "$AHEAD_BEHIND" | awk '{print $2}')
    SYNC_PARTS=""
    [ "$AHEAD" -gt 0 ] && SYNC_PARTS="\033[36m⇡${AHEAD}\033[0m"
    if [ "$BEHIND" -gt 0 ]; then
      [ -n "$SYNC_PARTS" ] && SYNC_PARTS="$SYNC_PARTS "
      SYNC_PARTS="${SYNC_PARTS}\033[33m⇣${BEHIND}\033[0m"
    fi
    [ -n "$SYNC_PARTS" ] && GIT_SYNC_STATUS=" $SYNC_PARTS"
  fi
fi

# Calculate time remaining in 5h window
FIVE_HOUR_REMAINING=""
if [ -n "$FIVE_HOUR_RESETS" ]; then
  NOW=$(date +%s)
  SECS_LEFT=$(( FIVE_HOUR_RESETS - NOW ))
  if [ "$SECS_LEFT" -gt 0 ]; then
    HOURS_LEFT=$(( SECS_LEFT / 3600 ))
    MINS_LEFT=$(( (SECS_LEFT % 3600) / 60 ))
    if [ "$HOURS_LEFT" -gt 0 ]; then
      FIVE_HOUR_REMAINING=" ${HOURS_LEFT}h${MINS_LEFT}m"
    else
      FIVE_HOUR_REMAINING=" ${MINS_LEFT}m"
    fi
  fi
fi

# Build rate limit info
RATE_INFO=""
if [ -n "$FIVE_HOUR" ]; then
  RATE_INFO=" \033[90m[5h: $(printf '%.0f' "$FIVE_HOUR")%${FIVE_HOUR_REMAINING}"
  if [ -n "$SEVEN_DAY" ]; then
    RATE_INFO="${RATE_INFO} 7d: $(printf '%.0f' "$SEVEN_DAY")%"
  fi
  RATE_INFO="${RATE_INFO}]\033[0m"
elif [ -n "$SEVEN_DAY" ]; then
  RATE_INFO=" \033[90m[7d: $(printf '%.0f' "$SEVEN_DAY")%]\033[0m"
fi

# Output format: [Model] [percentage] 📁 directory  branch +added -deleted ⇡ahead ⇣behind [5h: X% 7d: Y%]
# Use ANSI color codes: cyan for model, white for directory, green for branch
echo -e "\033[36m🤖 $MODEL_DISPLAY\033[0m$CONTEXT_PERCENT \033[37m📁 $DIR_NAME\033[0m$GIT_BRANCH$GIT_DIFF_STATS$GIT_SYNC_STATUS$RATE_INFO"
