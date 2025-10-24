#!/usr/bin/env bash
# Generate performance comparison report
# Usage: generate-performance-report.sh <os_name> <profiles> <pr_times_json> <base_times_json> <pr_tmux_times_json> <base_tmux_times_json> <output_file>

set -e

if [ "$#" -ne 7 ]; then
  echo "Usage: $0 <os_name> <profiles> <pr_times_json> <base_times_json> <pr_tmux_times_json> <base_tmux_times_json> <output_file>"
  exit 1
fi

OS_NAME="$1"
PROFILES="$2"
PR_TIMES_JSON="$3"
BASE_TIMES_JSON="$4"
PR_TMUX_TIMES_JSON="$5"
BASE_TMUX_TIMES_JSON="$6"
OUTPUT_FILE="$7"

# Read the JSON files (non-tmux)
PR_BASH=$(jq -r '.bash.median' "$PR_TIMES_JSON")
PR_ZSH=$(jq -r '.zsh.median' "$PR_TIMES_JSON")
PR_FISH=$(jq -r '.fish.median' "$PR_TIMES_JSON")

BASE_BASH=$(jq -r '.bash.median' "$BASE_TIMES_JSON")
BASE_ZSH=$(jq -r '.zsh.median' "$BASE_TIMES_JSON")
BASE_FISH=$(jq -r '.fish.median' "$BASE_TIMES_JSON")

# Read the JSON files (with tmux)
PR_TMUX_BASH=$(jq -r '.bash.median' "$PR_TMUX_TIMES_JSON")
PR_TMUX_ZSH=$(jq -r '.zsh.median' "$PR_TMUX_TIMES_JSON")
PR_TMUX_FISH=$(jq -r '.fish.median' "$PR_TMUX_TIMES_JSON")

BASE_TMUX_BASH=$(jq -r '.bash.median' "$BASE_TMUX_TIMES_JSON")
BASE_TMUX_ZSH=$(jq -r '.zsh.median' "$BASE_TMUX_TIMES_JSON")
BASE_TMUX_FISH=$(jq -r '.fish.median' "$BASE_TMUX_TIMES_JSON")

# Helper function to calculate percentage, handling divide by zero
calc_percent() {
  local diff=$1
  local base=$2
  if (( $(echo "$base == 0" | bc -l) )); then
    echo "N/A"
  else
    echo "scale=1; ($diff / $base) * 100" | bc
  fi
}

# Calculate differences and percentages (non-tmux)
BASH_DIFF=$(echo "$PR_BASH - $BASE_BASH" | bc)
BASH_PCT=$(calc_percent "$BASH_DIFF" "$BASE_BASH")

ZSH_DIFF=$(echo "$PR_ZSH - $BASE_ZSH" | bc)
ZSH_PCT=$(calc_percent "$ZSH_DIFF" "$BASE_ZSH")

FISH_DIFF=$(echo "$PR_FISH - $BASE_FISH" | bc)
FISH_PCT=$(calc_percent "$FISH_DIFF" "$BASE_FISH")

# Calculate differences and percentages (with tmux)
TMUX_BASH_DIFF=$(echo "$PR_TMUX_BASH - $BASE_TMUX_BASH" | bc)
TMUX_BASH_PCT=$(calc_percent "$TMUX_BASH_DIFF" "$BASE_TMUX_BASH")

TMUX_ZSH_DIFF=$(echo "$PR_TMUX_ZSH - $BASE_TMUX_ZSH" | bc)
TMUX_ZSH_PCT=$(calc_percent "$TMUX_ZSH_DIFF" "$BASE_TMUX_ZSH")

TMUX_FISH_DIFF=$(echo "$PR_TMUX_FISH - $BASE_TMUX_FISH" | bc)
TMUX_FISH_PCT=$(calc_percent "$TMUX_FISH_DIFF" "$BASE_TMUX_FISH")

# Determine emoji based on performance change
get_emoji() {
  local diff=$1
  if (( $(echo "$diff < 0" | bc -l) )); then
    echo "🚀" # Faster
  elif (( $(echo "$diff > 5" | bc -l) )); then
    echo "⚠️" # Slower by more than 5ms
  else
    echo "✅" # Roughly the same
  fi
}

BASH_EMOJI=$(get_emoji "$BASH_DIFF")
ZSH_EMOJI=$(get_emoji "$ZSH_DIFF")
FISH_EMOJI=$(get_emoji "$FISH_DIFF")

TMUX_BASH_EMOJI=$(get_emoji "$TMUX_BASH_DIFF")
TMUX_ZSH_EMOJI=$(get_emoji "$TMUX_ZSH_DIFF")
TMUX_FISH_EMOJI=$(get_emoji "$TMUX_FISH_DIFF")

# Format the comment
cat > "$OUTPUT_FILE" <<EOF
## Shell Startup Performance Report ($OS_NAME)

### Without tmux

| Shell | Base (ms) | PR (ms) | Diff (ms) | % Change | Status |
|-------|-----------|---------|-----------|----------|--------|
| Bash  | ${BASE_BASH} | ${PR_BASH} | ${BASH_DIFF} | ${BASH_PCT}% | ${BASH_EMOJI} |
| Zsh   | ${BASE_ZSH} | ${PR_ZSH} | ${ZSH_DIFF} | ${ZSH_PCT}% | ${ZSH_EMOJI} |
| Fish  | ${BASE_FISH} | ${PR_FISH} | ${FISH_DIFF} | ${FISH_PCT}% | ${FISH_EMOJI} |

### With tmux auto-start

| Shell | Base (ms) | PR (ms) | Diff (ms) | % Change | Status |
|-------|-----------|---------|-----------|----------|--------|
| Bash  | ${BASE_TMUX_BASH} | ${PR_TMUX_BASH} | ${TMUX_BASH_DIFF} | ${TMUX_BASH_PCT}% | ${TMUX_BASH_EMOJI} |
| Zsh   | ${BASE_TMUX_ZSH} | ${PR_TMUX_ZSH} | ${TMUX_ZSH_DIFF} | ${TMUX_ZSH_PCT}% | ${TMUX_ZSH_EMOJI} |
| Fish  | ${BASE_TMUX_FISH} | ${PR_TMUX_FISH} | ${TMUX_FISH_DIFF} | ${TMUX_FISH_PCT}% | ${TMUX_FISH_EMOJI} |

**Profiles tested:** \`${PROFILES}\`

### Legend
- 🚀 Faster than base
- ✅ Similar performance (within 5ms)
- ⚠️ Slower by more than 5ms

<details>
<summary>Detailed Results</summary>

**Base Branch (no tmux):**
\`\`\`json
$(cat "$BASE_TIMES_JSON")
\`\`\`

**PR Branch (no tmux):**
\`\`\`json
$(cat "$PR_TIMES_JSON")
\`\`\`

**Base Branch (with tmux):**
\`\`\`json
$(cat "$BASE_TMUX_TIMES_JSON")
\`\`\`

**PR Branch (with tmux):**
\`\`\`json
$(cat "$PR_TMUX_TIMES_JSON")
\`\`\`

</details>

---
*Median of 20 iterations after 3 warmup runs. Lower is better.*
EOF

echo "Performance report generated: $OUTPUT_FILE"
