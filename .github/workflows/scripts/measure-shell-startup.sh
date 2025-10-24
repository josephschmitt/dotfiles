#!/bin/bash
# Measures shell startup time for bash, zsh, and fish
# Outputs results in JSON format for easy parsing

set -e

# Number of iterations for median calculation
ITERATIONS=${1:-20}
OUTPUT_FILE=${2:-startup-times.json}
WITH_TMUX=${3:-false}

# Function to measure shell startup time
measure_shell() {
    local shell=$1
    local shell_cmd=$2
    local times=()

    if [ "$WITH_TMUX" = "true" ]; then
        echo "Measuring $shell startup time in tmux ($ITERATIONS iterations + 3 warmup)..." >&2
    else
        echo "Measuring $shell startup time ($ITERATIONS iterations + 3 warmup)..." >&2
    fi

    # Warmup runs to stabilize caches and avoid cold-start penalties
    for i in $(seq 1 3); do
        if [ "$WITH_TMUX" = "true" ]; then
            tmux new-session -d -s "warmup-$shell-$i" "$shell_cmd -c 'exit'" 2>/dev/null || true
            tmux kill-session -t "warmup-$shell-$i" 2>/dev/null || true
        else
            $shell_cmd -c "exit" >/dev/null 2>&1
        fi
    done

    # Actual measurements
    for i in $(seq 1 $ITERATIONS); do
        if [ "$WITH_TMUX" = "true" ]; then
            # Measure tmux session creation + shell startup
            result=$( (time -p tmux new-session -d -s "test-$shell-$i" "$shell_cmd -c 'exit'" 2>&1 >/dev/null) 2>&1 | grep real | awk '{print $2}')
            tmux kill-session -t "test-$shell-$i" 2>/dev/null || true
        else
            # Measure just shell startup
            result=$( (time -p $shell_cmd -c "exit" 2>&1 >/dev/null) 2>&1 | grep real | awk '{print $2}')
        fi

        # Convert to milliseconds (multiply by 1000)
        time_ms=$(echo "$result * 1000" | bc)
        times+=($time_ms)
    done

    # Sort times for median calculation
    IFS=$'\n' sorted_times=($(sort -n <<<"${times[*]}"))
    unset IFS

    # Calculate median (more robust against outliers than mean)
    local count=${#sorted_times[@]}
    if (( count % 2 == 0 )); then
        local mid1=$(( count / 2 - 1 ))
        local mid2=$(( count / 2 ))
        median=$(echo "scale=2; (${sorted_times[$mid1]} + ${sorted_times[$mid2]}) / 2" | bc)
    else
        local mid=$(( count / 2 ))
        median=${sorted_times[$mid]}
    fi

    # Calculate min and max
    min=${sorted_times[0]}
    max=${sorted_times[$((count - 1))]}

    echo "$median|$min|$max"
}

# Check if shells are available
command -v bash >/dev/null 2>&1 || { echo "bash not found" >&2; exit 1; }
command -v zsh >/dev/null 2>&1 || { echo "zsh not found" >&2; exit 1; }
command -v fish >/dev/null 2>&1 || { echo "fish not found" >&2; exit 1; }

# Check if tmux is available when WITH_TMUX is true
if [ "$WITH_TMUX" = "true" ]; then
    command -v tmux >/dev/null 2>&1 || { echo "tmux not found but WITH_TMUX=true" >&2; exit 1; }
fi

# Measure each shell
if [ "$WITH_TMUX" = "true" ]; then
    echo "Starting shell performance measurements (with tmux)..." >&2
else
    echo "Starting shell performance measurements..." >&2
fi
echo "" >&2

# Disable auto_start_tmux for Fish when testing
export SKIP_AUTO_TMUX=1

bash_result=$(measure_shell "bash" "bash -i -l")
bash_median=$(echo $bash_result | cut -d'|' -f1)
bash_min=$(echo $bash_result | cut -d'|' -f2)
bash_max=$(echo $bash_result | cut -d'|' -f3)

zsh_result=$(measure_shell "zsh" "zsh -i -l")
zsh_median=$(echo $zsh_result | cut -d'|' -f1)
zsh_min=$(echo $zsh_result | cut -d'|' -f2)
zsh_max=$(echo $zsh_result | cut -d'|' -f3)

fish_result=$(measure_shell "fish" "fish -i -l")
fish_median=$(echo $fish_result | cut -d'|' -f1)
fish_min=$(echo $fish_result | cut -d'|' -f2)
fish_max=$(echo $fish_result | cut -d'|' -f3)

# Output JSON
cat > "$OUTPUT_FILE" <<EOF
{
  "bash": {
    "median": $bash_median,
    "min": $bash_min,
    "max": $bash_max
  },
  "zsh": {
    "median": $zsh_median,
    "min": $zsh_min,
    "max": $zsh_max
  },
  "fish": {
    "median": $fish_median,
    "min": $fish_min,
    "max": $fish_max
  }
}
EOF

echo "" >&2
echo "Results written to $OUTPUT_FILE" >&2
