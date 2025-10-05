function ssh -d "SSH wrapper that detaches from tmux before connecting"
    if set -q TMUX
        # Detach from tmux and run SSH outside it
        tmux detach-client -E "command ssh $argv"
    else
        # Not in tmux, just run SSH normally
        command ssh $argv
    end
end
