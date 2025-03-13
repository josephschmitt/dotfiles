#!/bin/bash
# Usage: ./github_permalink.sh <file_path> [line_number]

# Check for at least one argument.
if [ $# -lt 1 ]; then
    echo "Usage: $(basename "$0") <file_path> [line_number]" >&2
    exit 1
fi

# Expand the file path (handles ~)
FILE=$(eval echo "$1")
if [ ! -f "$FILE" ]; then
    echo "Error: File not found: $FILE" >&2
    exit 1
fi

# Determine the directory of the provided file.
FILE_DIR=$(dirname "$FILE")

# Pushd into the file's directory so git commands are relative to it.
pushd "$FILE_DIR" > /dev/null || { echo "Error: Could not change directory to $FILE_DIR" >&2; exit 1; }

# Look up the git repository root from the file's directory.
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "Error: Not inside a git repository." >&2
    popd > /dev/null
    exit 1
fi

# Pop back to the original directory.
popd > /dev/null

# Ensure the file is located within the git repository.
if [[ "$FILE" != "$REPO_ROOT"* ]]; then
    echo "Error: The file '$FILE' is not located within the git repository root '$REPO_ROOT'." >&2
    exit 1
fi

# Get the remote origin URL from the repository configuration.
REMOTE_URL=$(git -C "$REPO_ROOT" config --get remote.origin.url)
if [ -z "$REMOTE_URL" ]; then
    echo "Error: Remote origin URL not found in git config." >&2
    exit 1
fi

# Get the current branch name.
BRANCH=$(git -C "$REPO_ROOT" rev-parse --abbrev-ref HEAD)

# Choose a Python interpreter: prefer 'python', fallback to 'python3'
if command -v python &>/dev/null; then
    PYTHON_CMD=python
elif command -v python3 &>/dev/null; then
    PYTHON_CMD=python3
else
    echo "Error: Neither python nor python3 is installed." >&2
    exit 1
fi

# Calculate the file's relative path from the repository root.
RELATIVE_PATH=$($PYTHON_CMD -c "import os,sys; print(os.path.relpath(os.path.abspath(sys.argv[1]), os.path.abspath(sys.argv[2])))" "$FILE" "$REPO_ROOT")

# Convert the remote URL to a GitHub HTTPS URL.
if [[ "$REMOTE_URL" =~ ^git@github.com: ]]; then
    # Convert SSH URL to HTTPS.
    GITHUB_URL="https://github.com/${REMOTE_URL#git@github.com:}"
    GITHUB_URL=${GITHUB_URL%.git}
elif [[ "$REMOTE_URL" =~ ^https://github.com/ ]]; then
    GITHUB_URL="${REMOTE_URL%.git}"
else
    echo "Error: Remote URL does not appear to be a GitHub URL." >&2
    exit 1
fi

# Build the permalink.
PERMALINK="${GITHUB_URL}/blob/${BRANCH}/${RELATIVE_PATH}"
if [ $# -ge 2 ]; then
    LINE_NUMBER="$2"
    PERMALINK="${PERMALINK}#L${LINE_NUMBER}"
fi

echo "$PERMALINK"
