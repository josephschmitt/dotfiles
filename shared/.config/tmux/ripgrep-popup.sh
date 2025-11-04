#!/usr/bin/env bash
# Ripgrep search popup for tmux
# Based on https://junegunn.github.io/fzf/tips/ripgrep-integration/

# Start with empty list, only show results when user types
# --no-ignore-vcs: ignore .gitignore but respect .ignore files
# --hidden: search hidden files/directories (like .config)
# --glob '!.git': exclude .git directories
RG_PREFIX="rg --column --color=always --smart-case --no-ignore-vcs --hidden --glob '!.git'"
INITIAL_QUERY="${*:-}"

: | fzf --disabled --ansi --multi \
    --bind "start:reload:$RG_PREFIX {q} || :" \
    --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || :" \
    --bind "enter:execute(popup-aware-editor {1} +{2})" \
    --bind "ctrl-o:execute(popup-aware-editor --no-rpc {1} +{2})" \
    --bind 'alt-a:select-all,alt-d:deselect-all,ctrl-/:toggle-preview' \
    --delimiter : \
    --preview 'bat --style=full --color=always --highlight-line {2} {1}' \
    --preview-window '~4,+{2}+4/3,<80(up)' \
    --border-label ' Ripgrep ' \
    --prompt '🔍 > ' \
    --header 'Type to search...' \
    --query "$INITIAL_QUERY"
