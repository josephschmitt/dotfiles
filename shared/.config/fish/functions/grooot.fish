function grooot --description "cd to the main repo root, even from a worktree"
    set common_dir (git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
    or begin
        echo "Not in a git repo" >&2
        return 1
    end
    set root (path dirname $common_dir)
    echo "I am Grooot! "(set_color brblack)(string replace -r "^$HOME" "~" $root)(set_color normal)
    cd $root
end
