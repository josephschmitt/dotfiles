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

# Use television with inline ripgrep source command
tv \
  --source-command "rg --column --line-number --no-heading --color=always --smart-case --hidden --glob '!.git' '${ESCAPED_QUERY}' 2>/dev/null || true" \
  --ansi \
  --preview-command 'bat --style=full --color=always --highlight-line $(echo {} | cut -d: -f2) $(echo {} | cut -d: -f1) 2>/dev/null' \
  --preview-size 55 \
  --input-header "Ripgrep: ${INITIAL_QUERY}" \
  --input-prompt "🔍 " \
  --layout landscape \
  --no-remote \
  --hide-help-panel \
  --source-output '{split::0}:{split::1}' || true
