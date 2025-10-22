#!/bin/bash
# Measures shell startup time for bash, zsh, and fish
# Outputs results in JSON format for easy parsing

set -e

# Number of iterations for averaging
ITERATIONS=${1:-10}
OUTPUT_FILE=${2:-startup-times.json}

# Function to measure shell startup time
measure_shell() {
    local shell=$1
    local shell_cmd=$2
    local total=0
    local times=()

    echo "Measuring $shell startup time ($ITERATIONS iterations)..." >&2

    for i in $(seq 1 $ITERATIONS); do
        # Use GNU time format to get real time in milliseconds
        # The command just starts the shell and immediately exits
        result=$( (time -p $shell_cmd -c "exit" 2>&1 >/dev/null) 2>&1 | grep real | awk '{print $2}')

        # Convert to milliseconds (multiply by 1000)
        time_ms=$(echo "$result * 1000" | bc)
        times+=($time_ms)
        total=$(echo "$total + $time_ms" | bc)
    done

    # Calculate average
    avg=$(echo "scale=2; $total / $ITERATIONS" | bc)

    # Calculate min and max
    min=${times[0]}
    max=${times[0]}
    for time in "${times[@]}"; do
        if (( $(echo "$time < $min" | bc -l) )); then
            min=$time
        fi
        if (( $(echo "$time > $max" | bc -l) )); then
            max=$time
        fi
    done

    echo "$avg|$min|$max"
}

# Check if shells are available
command -v bash >/dev/null 2>&1 || { echo "bash not found" >&2; exit 1; }
command -v zsh >/dev/null 2>&1 || { echo "zsh not found" >&2; exit 1; }
command -v fish >/dev/null 2>&1 || { echo "fish not found" >&2; exit 1; }

# Measure each shell
echo "Starting shell performance measurements..." >&2
echo "" >&2

bash_result=$(measure_shell "bash" "bash -i -l")
bash_avg=$(echo $bash_result | cut -d'|' -f1)
bash_min=$(echo $bash_result | cut -d'|' -f2)
bash_max=$(echo $bash_result | cut -d'|' -f3)

zsh_result=$(measure_shell "zsh" "zsh -i -l")
zsh_avg=$(echo $zsh_result | cut -d'|' -f1)
zsh_min=$(echo $zsh_result | cut -d'|' -f2)
zsh_max=$(echo $zsh_result | cut -d'|' -f3)

fish_result=$(measure_shell "fish" "fish -i -l")
fish_avg=$(echo $fish_result | cut -d'|' -f1)
fish_min=$(echo $fish_result | cut -d'|' -f2)
fish_max=$(echo $fish_result | cut -d'|' -f3)

# Output JSON
cat > "$OUTPUT_FILE" <<EOF
{
  "bash": {
    "avg": $bash_avg,
    "min": $bash_min,
    "max": $bash_max
  },
  "zsh": {
    "avg": $zsh_avg,
    "min": $zsh_min,
    "max": $zsh_max
  },
  "fish": {
    "avg": $fish_avg,
    "min": $fish_min,
    "max": $fish_max
  }
}
EOF

echo "" >&2
echo "Results written to $OUTPUT_FILE" >&2
