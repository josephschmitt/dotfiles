# Television shell integration (Ctrl+R history, Ctrl+T smart autocomplete)
if status is-interactive; and command -v tv >/dev/null
    tv init fish | source
end
