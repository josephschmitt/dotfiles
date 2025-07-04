#!/bin/bash
# Usage: ./github_permalink.sh <file_path> [line_number]

# --- Configuration ---
# Choose a Python interpreter: prefer 'python3', fallback to 'python'
if command -v python3 &>/dev/null; then
    PYTHON_CMD=python3
elif command -v python &>/dev/null; then
    PYTHON_CMD=python
else
    echo "Error: Neither python3 nor python is installed or found in PATH." >&2
    exit 1
fi

# --- Argument Handling ---
if [ $# -lt 1 ]; then
    echo "Usage: $(basename "$0") <file_path> [line_number]" >&2
    exit 1
fi

INPUT_PATH="$1"
LINE_NUMBER=""
if [ $# -ge 2 ]; then
    # Basic check if the second argument looks like a positive integer
    if [[ "$2" =~ ^[1-9][0-9]*$ ]]; then
        LINE_NUMBER="$2"
    else
        echo "Warning: Second argument '$2' does not look like a valid line number. Ignoring." >&2
    fi
fi

# --- Path Canonicalization ---
# Convert input path (absolute, relative, or ~) to an absolute path.
# Prefer realpath, then readlink -f, then Python.
if command -v realpath &>/dev/null; then
    ABSOLUTE_FILE_PATH=$(realpath "$INPUT_PATH" 2>/dev/null)
elif command -v readlink &>/dev/null && readlink -f / &>/dev/null; then # Check if readlink supports -f
    ABSOLUTE_FILE_PATH=$(readlink -f "$INPUT_PATH" 2>/dev/null)
else
    # Use Python as a fallback for robust absolute path calculation
    ABSOLUTE_FILE_PATH=$($PYTHON_CMD -c "import os, sys; print(os.path.abspath(os.path.expanduser(sys.argv[1])))" "$INPUT_PATH" 2>/dev/null)
fi

# Check if path canonicalization succeeded and the file exists
if [ -z "$ABSOLUTE_FILE_PATH" ] || [ ! -f "$ABSOLUTE_FILE_PATH" ]; then
    # Try to provide a more specific error if realpath/readlink failed vs python
    if [ -e "$INPUT_PATH" ] && [ ! -f "$INPUT_PATH" ]; then
         echo "Error: Input path exists but is not a regular file: $INPUT_PATH" >&2
    else
         echo "Error: File not found or could not determine absolute path for: $INPUT_PATH" >&2
    fi
    exit 1
fi

# --- Git Repository Detection ---
# Determine the directory containing the file.
FILE_DIR=$(dirname "$ABSOLUTE_FILE_PATH")

# Look up the git repository root starting from the file's directory.
# This handles cases where the script is run outside the repo but the file is inside.
REPO_ROOT=$(git -C "$FILE_DIR" rev-parse --show-toplevel 2>/dev/null)
if [ $? -ne 0 ] || [ -z "$REPO_ROOT" ]; then
    echo "Error: Could not find git repository root containing file: $ABSOLUTE_FILE_PATH" >&2
    exit 1
fi

# Ensure the file is located within the detected git repository.
# Use string prefix matching for robustness.
if [[ "$ABSOLUTE_FILE_PATH" != "$REPO_ROOT/"* ]] && [[ "$ABSOLUTE_FILE_PATH" != "$REPO_ROOT" ]]; then
    echo "Error: The file '$ABSOLUTE_FILE_PATH' is not located within the git repository root '$REPO_ROOT'." >&2
    exit 1
fi

# --- Git Information Retrieval ---
# Get the remote origin URL from the repository configuration.
REMOTE_URL=$(git -C "$REPO_ROOT" config --get remote.origin.url)
if [ -z "$REMOTE_URL" ]; then
    echo "Error: Remote 'origin' URL not found in git config for repository: $REPO_ROOT" >&2
    exit 1
fi

# Get the current commit SHA (more permanent than branch name).
# Using the full SHA makes it a true permalink, unaffected by branch changes/deletions.
COMMIT_SHA=$(git -C "$REPO_ROOT" rev-parse HEAD)
if [ $? -ne 0 ] || [ -z "$COMMIT_SHA" ]; then
     echo "Error: Could not get current commit SHA for repository: $REPO_ROOT" >&2
     exit 1
fi

# --- Path Calculation within Repo ---
# Calculate the file's relative path from the repository root.
# Use Python for robust relative path calculation. Both paths are already absolute.
RELATIVE_PATH=$($PYTHON_CMD -c "import os, sys; print(os.path.relpath(sys.argv[1], sys.argv[2]))" "$ABSOLUTE_FILE_PATH" "$REPO_ROOT")
if [ -z "$RELATIVE_PATH" ]; then
    echo "Error: Could not calculate relative path for '$ABSOLUTE_FILE_PATH' within '$REPO_ROOT'." >&2
    exit 1
fi

# --- URL Conversion ---
# Convert the remote URL to a GitHub HTTPS URL.
if [[ "$REMOTE_URL" =~ ^git@github\.com:([^/]+)/(.+) ]]; then
    # Convert SSH URL (git@github.com:user/repo.git)
    ORG_USER="${BASH_REMATCH[1]}"
    REPO_NAME="${BASH_REMATCH[2]}"
    GITHUB_URL="https://github.com/${ORG_USER}/${REPO_NAME%.git}"
elif [[ "$REMOTE_URL" =~ ^https://github\.com/([^/]+)/(.+) ]]; then
    # Handle HTTPS URL (https://github.com/user/repo.git or https://github.com/user/repo)
    ORG_USER="${BASH_REMATCH[1]}"
    REPO_NAME="${BASH_REMATCH[2]}"
    GITHUB_URL="https://github.com/${ORG_USER}/${REPO_NAME%.git}"
elif [[ "$REMOTE_URL" =~ ^ssh://git@github\.com/([^/]+)/(.+) ]]; then
    # Convert SSH URL (ssh://git@github.com/user/repo.git)
    ORG_USER="${BASH_REMATCH[1]}"
    REPO_NAME="${BASH_REMATCH[2]}"
    GITHUB_URL="https://github.com/${ORG_USER}/${REPO_NAME%.git}"
else
    echo "Error: Remote URL '$REMOTE_URL' does not appear to be a standard GitHub SSH or HTTPS URL." >&2
    exit 1
fi

# --- Permalink Construction ---
# Build the permalink using the commit SHA for permanence.
PERMALINK="${GITHUB_URL}/blob/${COMMIT_SHA}/${RELATIVE_PATH}"
if [ -n "$LINE_NUMBER" ]; then
    PERMALINK="${PERMALINK}#L${LINE_NUMBER}"
fi

# --- Output ---
echo "$PERMALINK"
