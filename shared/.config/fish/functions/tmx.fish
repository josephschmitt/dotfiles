function tmx
    set -l dir (if test (count $argv) -gt 0; echo $argv[1]; else; pwd; end)
    cd $dir; or return 1
    tmux new-session -A -s (basename $dir)
    exit
end