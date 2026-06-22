#!/usr/bin/env bash

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

# Extract session cost
SESSION_COST=""
COST_USD=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
if [ -n "$COST_USD" ] && [ "$COST_USD" != "null" ] && [ "$COST_USD" != "0" ]; then
  COST_FORMATTED=$(echo "$COST_USD" | awk '{printf "%.2f", $1}')
  SESSION_COST=" \033[33m💸 \$${COST_FORMATTED}\033[0m"
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

# --- LLM Budget Usage ---
BUDGET_DISPLAY=""
CACHE_FILE="/tmp/claude-budget-usage-$(whoami).json"
CACHE_TTL="${LLM_BUDGET_CACHE_TTL:-60}"  # Default 1 minute; override with LLM_BUDGET_CACHE_TTL env var — if this grows significantly, consider adding a "last updated" age indicator to BUDGET_DISPLAY
COMPASS_API_V3_HOST="${COMPASS_API_V3_HOST:-www.compass.com}"

fetch_budget() {
  local key
  key=$(compass config get llm-proxy-key 2>/dev/null)
  if [ -n "$key" ]; then
    local resp
    if resp=$(curl -s --max-time 5 -X POST \
      "https://${COMPASS_API_V3_HOST}/api/v3/litellm_management/budget_usage" \
      -H 'Content-Type: application/json' \
      -d "$(jq -n --arg key "$key" '{key: $key}')") && echo "$resp" | jq -e '.spend' >/dev/null 2>&1; then
      echo "$resp" | jq --arg ts "$(date +%s)" '. + {timestamp: ($ts|tonumber)}' > "${CACHE_FILE}.tmp" \
        && chmod 600 "${CACHE_FILE}.tmp" \
        && mv "${CACHE_FILE}.tmp" "$CACHE_FILE"
    fi
  fi
}

# Check cache freshness
NOW=$(date +%s)
if [ -f "$CACHE_FILE" ]; then
  CACHE_TS=$(jq -r '.timestamp // 0' "$CACHE_FILE" 2>/dev/null)
  AGE=$(( NOW - CACHE_TS ))
  if [ "$AGE" -gt "$CACHE_TTL" ]; then
    # Refresh in background, use stale data this render
    fetch_budget &
  fi
else
  # No cache — fetch synchronously on first run
  fetch_budget
fi

# Read from cache (stale or fresh) — cache only exists after a successful fetch with a valid key
if [ -f "$CACHE_FILE" ]; then
  SPEND=$(jq -r '.spend // empty' "$CACHE_FILE" 2>/dev/null)
  MAX_BUDGET=$(jq -r '.maxBudget // empty' "$CACHE_FILE" 2>/dev/null)

  if [ -n "$SPEND" ]; then
    # Add current session cost to cached spend for real-time tracking between cache refreshes
    if [ -n "$COST_USD" ]; then
      SPEND=$(echo "$SPEND $COST_USD" | awk '{printf "%.8f", $1 + $2}')
    fi
    SPEND_FMT=$(printf "%.2f" "$SPEND")
    if [ -n "$MAX_BUDGET" ]; then
      # 999999 is the Compass LLM proxy sentinel for the "Unlimited" tier
      if echo "$MAX_BUDGET" | awk '{exit !($1 >= 999999)}'; then
        BUDGET_DISPLAY=" \033[32m💰 \$${SPEND_FMT} · Unlimited\033[0m"
      else
        MAX_FMT=$(printf "%.2f" "$MAX_BUDGET")
        # Calculate percentage for color
        PCT=$(echo "$SPEND $MAX_BUDGET" | awk '{if ($2 == 0) print 0; else printf "%d", ($1/$2)*100}')
        if [ "$PCT" -le 50 ]; then
          BUDGET_COLOR="\033[32m"
        elif [ "$PCT" -le 80 ]; then
          BUDGET_COLOR="\033[33m"
        else
          BUDGET_COLOR="\033[31m"
        fi
        BUDGET_DURATION=$(jq -r '.budgetDuration // empty' "$CACHE_FILE" 2>/dev/null)
        DURATION_SUFFIX=""
        [ -n "$BUDGET_DURATION" ] && DURATION_SUFFIX="/${BUDGET_DURATION}"
        BUDGET_DISPLAY=" ${BUDGET_COLOR}💰 \$${SPEND_FMT}/\$${MAX_FMT}${DURATION_SUFFIX}\033[0m"
      fi
    else
      BUDGET_DISPLAY=" \033[37m💰 \$${SPEND_FMT}\033[0m"
    fi
  fi
fi

# Output format: [Model] [percentage] 📁 directory  branch +added -deleted ⇡ahead ⇣behind
# Use ANSI color codes: cyan for model, white for directory, green for branch
echo -e "\033[36m🤖 $MODEL_DISPLAY\033[0m$CONTEXT_PERCENT$SESSION_COST$BUDGET_DISPLAY \033[37m📁 $DIR_NAME\033[0m$GIT_BRANCH$GIT_DIFF_STATS$GIT_SYNC_STATUS"
