#!/usr/bin/env bash

# Ensure a directory is provided
directory="$1"
shift

# Initialize variables
key=""
value=""

# Parse flags
while [[ $# -gt 0 ]]; do
  case "$1" in
    --key)
      key="$2"
      shift 2
      ;;
    --value)
      value="$2"
      shift 2
      ;;
    *)
      echo "Usage: $0 <directory> --key <key> --value <value>" >&2
      exit 1
      ;;
  esac
done

# Print Coloring Functions
function green {
  echo $'\e[1;32m'"$*"$'\e[0m'
}

function red {
  echo $'\e[1;31m'"$*"$'\e[0m'
}

function cyan {
  echo $'\e[1;36m'"$*"$'\e[0m'
}

function magenta {
  echo $'\e[1;35m'"$*"$'\e[0m'
}

# Ensure all required arguments are provided
if [ -z "$directory" ] || [ -z "$key" ] || [ -z "$value" ]; then
  echo "Usage: $0 <directory> --key <key> --value <value>" >&2
  exit 1
fi

# Initialize counters
total_files=0
matched_files=0

# Use process substitution so that variables update in the same shell
while IFS= read -r file; do
  total_files=$((total_files + 1))
  if grep "^[[:space:]]*$key:[[:space:]]*$value" "$file" > /dev/null 2>&1; then
    # Print matched file to stdout
    echo "$(dirname ${file#$directory/})"
    matched_files=$((matched_files + 1))
  fi
done < <(find "$directory" -type f -name "catalog-info.yaml")

# Conditionally color the matched files count
if [ "$matched_files" -gt 0 ]; then
  matched_color="$(green $matched_files)"
else
  matched_color="$(red $matched_files)"
fi

# Always color the total files in cyan
total_color="$(cyan $total_files)"

# Print summary to stderr
printf "\nFound %s matches out of %s %s files\n" $matched_color $total_color "$(magenta catalog-info.yaml)" >&2
