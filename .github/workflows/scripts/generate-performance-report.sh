#!/usr/bin/env bash
# Generate performance comparison report
# Usage: generate-performance-report.sh <os_name> <profiles> <pr_times_json> <base_times_json> <output_file>

set -e

if [ "$#" -ne 5 ]; then
  echo "Usage: $0 <os_name> <profiles> <pr_times_json> <base_times_json> <output_file>"
  exit 1
fi

OS_NAME="$1"
PROFILES="$2"
PR_TIMES_JSON="$3"
BASE_TIMES_JSON="$4"
OUTPUT_FILE="$5"

# Read the JSON files
PR_BASH=$(jq -r '.bash.median' "$PR_TIMES_JSON")
PR_ZSH=$(jq -r '.zsh.median' "$PR_TIMES_JSON")
PR_FISH=$(jq -r '.fish.median' "$PR_TIMES_JSON")

BASE_BASH=$(jq -r '.bash.median' "$BASE_TIMES_JSON")
BASE_ZSH=$(jq -r '.zsh.median' "$BASE_TIMES_JSON")
BASE_FISH=$(jq -r '.fish.median' "$BASE_TIMES_JSON")

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

# Calculate differences and percentages
BASH_DIFF=$(echo "$PR_BASH - $BASE_BASH" | bc)
BASH_PCT=$(calc_percent "$BASH_DIFF" "$BASE_BASH")

ZSH_DIFF=$(echo "$PR_ZSH - $BASE_ZSH" | bc)
ZSH_PCT=$(calc_percent "$ZSH_DIFF" "$BASE_ZSH")

FISH_DIFF=$(echo "$PR_FISH - $BASE_FISH" | bc)
FISH_PCT=$(calc_percent "$FISH_DIFF" "$BASE_FISH")

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

# Format the comment
cat > "$OUTPUT_FILE" <<EOF
## Shell Startup Performance Report ($OS_NAME)

| Shell | Base (ms) | PR (ms) | Diff (ms) | % Change | Status |
|-------|-----------|---------|-----------|----------|--------|
| Bash  | ${BASE_BASH} | ${PR_BASH} | ${BASH_DIFF} | ${BASH_PCT}% | ${BASH_EMOJI} |
| Zsh   | ${BASE_ZSH} | ${PR_ZSH} | ${ZSH_DIFF} | ${ZSH_PCT}% | ${ZSH_EMOJI} |
| Fish  | ${BASE_FISH} | ${PR_FISH} | ${FISH_DIFF} | ${FISH_PCT}% | ${FISH_EMOJI} |

**Profiles tested:** \`${PROFILES}\`

### Legend
- 🚀 Faster than base
- ✅ Similar performance (within 5ms)
- ⚠️ Slower by more than 5ms

<details>
<summary>Detailed Results</summary>

**Base Branch:**
\`\`\`json
$(cat "$BASE_TIMES_JSON")
\`\`\`

**PR Branch:**
\`\`\`json
$(cat "$PR_TIMES_JSON")
\`\`\`

</details>

---
*Median of 20 iterations after 3 warmup runs. Lower is better.*
EOF

echo "Performance report generated: $OUTPUT_FILE"
