function tmx
    set -l dir (if test (count $argv) -gt 0; echo $argv[1]; else; pwd; end)
    cd $dir; or return 1
    set -l session_name (basename $dir)
    
    if test -n "$TMUX"
        # Already in tmux, switch to session instead of nesting
        tmux new-session -A -d -s $session_name
        tmux switch-client -t $session_name
    else
        # Not in tmux, start new session normally
        tmux new-session -A -s $session_name
        exit
    end
end