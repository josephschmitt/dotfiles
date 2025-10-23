#!/usr/bin/env bash
# Post or update performance report comment on PR
# Usage: post-performance-comment.sh <os_name> <comment_file>

set -e

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <os_name> <comment_file>"
  exit 1
fi

OS_NAME="$1"
COMMENT_FILE="$2"

if [ ! -f "$COMMENT_FILE" ]; then
  echo "Error: Comment file not found: $COMMENT_FILE"
  exit 1
fi

COMMENT_BODY=$(cat "$COMMENT_FILE")
PR_NUMBER="${GITHUB_REF##*/}"

# Find existing comment with this OS name
EXISTING_COMMENT_ID=$(gh pr view "$PR_NUMBER" --json comments --jq ".comments[] | select(.body | contains(\"Shell Startup Performance Report ($OS_NAME)\")) | .id")

if [ -n "$EXISTING_COMMENT_ID" ]; then
  echo "Updating existing comment (ID: $EXISTING_COMMENT_ID) for $OS_NAME..."
  gh api \
    --method PATCH \
    -H "Accept: application/vnd.github+json" \
    "/repos/$GITHUB_REPOSITORY/issues/comments/$EXISTING_COMMENT_ID" \
    -f body="$COMMENT_BODY"
else
  echo "Creating new comment for $OS_NAME..."
  gh pr comment "$PR_NUMBER" --body "$COMMENT_BODY"
fi

echo "Comment posted successfully!"
