#!/usr/bin/env bash
# Ripgrep search using television
# Prompts for search query, then shows results with fuzzy filtering

# Accept optional initial query from arguments
INITIAL_QUERY="${*:-}"

# If no initial query, prompt for it
if [ -z "$INITIAL_QUERY" ]; then
  # Use a simple prompt to get search term
  printf "🔍 Search query: "
  read -r INITIAL_QUERY

  # Exit if no query provided
  [ -z "$INITIAL_QUERY" ] && exit 0
fi

# Escape single quotes in query for shell command
ESCAPED_QUERY="${INITIAL_QUERY//\'/\'\\\'\'}"

# Use television ripgrep channel with dynamic search query
# The channel provides preview, layout, and output configuration
# We only override the source command to inject the search term
tv ripgrep \
  --source-command "rg --column --line-number --no-heading --color=always --smart-case --hidden --glob '!.git' '${ESCAPED_QUERY}' 2>/dev/null || true" \
  --ansi \
  --input-header "Ripgrep: ${INITIAL_QUERY}" \
  --input-prompt "🔍 " \
  --no-remote \
  --hide-help-panel || true
