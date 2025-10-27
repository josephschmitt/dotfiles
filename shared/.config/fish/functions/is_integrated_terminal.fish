function is_integrated_terminal -d "Check if running in an IDE/editor integrated terminal"
    set -q VSCODE_INJECTION; or \
    set -q VSCODE_PID; or \
    test "$TERM_PROGRAM" = "vscode"; or \
    set -q INSIDE_EMACS; or \
    set -q ZED_TERM; or \
    set -q NVIM; or \
    set -q NVIM_LISTEN_ADDRESS
end
