function groot
    set root (git rev-parse --show-toplevel 2>/dev/null)
    or begin
        echo "Not in a git repo" >&2
        return 1
    end
    echo "I am Groot! "(set_color brblack)(string replace -r "^$HOME" "~" $root)(set_color normal)
    cd $root
end
