#!/usr/bin/env bash
# Ripgrep file finder using television
# Lists all files by default, or searches code if query provided

# Accept optional search query from arguments
SEARCH_QUERY="${*:-}"

if [ -z "$SEARCH_QUERY" ]; then
  # No search query - list all files that ripgrep would search
  tv ripgrep \
    --source-command "rg --files --hidden --glob '!.git' 2>/dev/null || true" \
    --input-header "Files" \
    --input-prompt "📁 " \
    --no-remote \
    --hide-help-panel || true
else
  # Search query provided - search code content
  ESCAPED_QUERY="${SEARCH_QUERY//\'/\'\\\'\'}"

  tv ripgrep \
    --source-command "rg --column --line-number --no-heading --color=always --smart-case --hidden --glob '!.git' '${ESCAPED_QUERY}' 2>/dev/null || true" \
    --ansi \
    --input-header "Ripgrep: ${SEARCH_QUERY}" \
    --input-prompt "🔍 " \
    --no-remote \
    --hide-help-panel || true
fi
