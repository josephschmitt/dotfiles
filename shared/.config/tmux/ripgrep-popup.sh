#!/usr/bin/env bash
# Ripgrep search popup for tmux
# Based on https://junegunn.github.io/fzf/tips/ripgrep-integration/
#
# Interactive file filtering:
#   --include *.yaml search term       → search only *.yaml files
#   --include *.{rs,toml} term         → search only *.rs and *.toml files
#   --exclude node_modules term        → exclude node_modules directory
#   --include src/** --exclude *.test.js term → combine filters
#   search term                        → search all files (default)

INITIAL_QUERY="${*:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

: | fzf --disabled --ansi --multi \
    --bind "start:reload:$SCRIPT_DIR/rg-filter {q} || :" \
    --bind "change:reload:sleep 0.1; $SCRIPT_DIR/rg-filter {q} || :" \
    --bind "enter:execute(popup-aware-editor {1} +{2})" \
    --bind "ctrl-o:execute(popup-aware-editor --no-rpc {1} +{2})" \
    --bind 'alt-a:select-all,alt-d:deselect-all,ctrl-/:toggle-preview' \
    --delimiter : \
    --preview 'bat --style=full --color=always --highlight-line {2} {1}' \
    --preview-window '~4,+{2}+4/3,<80(up)' \
    --border-label ' Ripgrep ' \
    --prompt '🔍 > ' \
    --header 'Type to search... (--include/--exclude patterns, e.g. --include *.yaml config)' \
    --query "$INITIAL_QUERY"
