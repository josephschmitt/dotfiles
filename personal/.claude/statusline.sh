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

# Render a Max-plan usage bar: <label> <colored bar> <NN%> <(reset countdown)>
# Uses literal \033 escapes; the final `echo -e` interprets them.
render_usage_bar() {
  local label="$1" pct="$2" resets_at="$3"
  local width=10

  # Percentages arrive as floats (e.g. 23.5); bash math is integer-only.
  local pct_int
  pct_int=$(printf '%.0f' "$pct")

  # Filled cells, rounded to nearest, clamped to [0, width].
  local filled=$(( (pct_int * width + 50) / 100 ))
  [ "$filled" -gt "$width" ] && filled=$width
  [ "$filled" -lt 0 ] && filled=0
  local empty=$(( width - filled ))

  # Threshold color, mirroring the context-window indicator above.
  local color
  if [ "$pct_int" -le 50 ]; then
    color='\033[32m'
  elif [ "$pct_int" -le 75 ]; then
    color='\033[33m'
  else
    color='\033[31m'
  fi

  # Build the bar: filled (colored) + empty (dim).
  local bar="" i
  for (( i = 0; i < filled; i++ )); do bar="${bar}█"; done
  local empty_bar=""
  for (( i = 0; i < empty; i++ )); do empty_bar="${empty_bar}░"; done

  # Reset countdown from epoch seconds (date +%s works on macOS & Linux).
  local countdown=""
  if [ -n "$resets_at" ] && [ "$resets_at" != "null" ]; then
    local now remaining
    now=$(date +%s)
    remaining=$(( resets_at - now ))
    if [ "$remaining" -gt 0 ]; then
      local days=$(( remaining / 86400 ))
      local hours=$(( (remaining % 86400) / 3600 ))
      local mins=$(( (remaining % 3600) / 60 ))
      local reset_txt
      if [ "$days" -gt 0 ]; then
        reset_txt="${days}d${hours}h"
      elif [ "$hours" -gt 0 ]; then
        reset_txt="${hours}h${mins}m"
      else
        reset_txt="${mins}m"
      fi
      countdown=" \033[90m(${reset_txt})\033[0m"
    fi
  fi

  printf '%s %s%s\033[90m%s\033[0m %s%d%%\033[0m%s' \
    "$label" "$color" "$bar" "$empty_bar" "$color" "$pct_int" "$countdown"
}

# Max-plan usage bar (5-hour window). The rate_limits block is only present
# for Max/Pro subscribers after the first API response; absent => no bar.
FIVE_H_PCT=$(echo "$input"   | jq -r '.rate_limits.five_hour.used_percentage // empty')
FIVE_H_RESET=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')

USAGE_BARS=""
[ -n "$FIVE_H_PCT" ] && USAGE_BARS="  $(render_usage_bar '⏳ 5h' "$FIVE_H_PCT" "$FIVE_H_RESET")"

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

# Output format: [Model] [percentage] 📁 directory  branch +added -deleted ⇡ahead ⇣behind
# Use ANSI color codes: cyan for model, white for directory, green for branch
echo -e "\033[36m🤖 $MODEL_DISPLAY\033[0m$CONTEXT_PERCENT \033[37m📁 $DIR_NAME\033[0m$GIT_BRANCH$GIT_DIFF_STATS$GIT_SYNC_STATUS$USAGE_BARS"
