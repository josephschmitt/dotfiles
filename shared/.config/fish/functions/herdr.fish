function herdr -d "Launch herdr, detaching from tmux if needed" -w herdr
    if set -q TMUX
        tmux detach-client -E "HERDR=1 command herdr $argv"
    else
        set -gx HERDR 1
        command herdr $argv
    end
end
