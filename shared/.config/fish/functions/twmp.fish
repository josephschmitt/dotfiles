# Convenience function to change directory and run twm
function twmp
    set target_dir (zq (test -z "$argv"; and echo "$PWD"; or echo "$argv"))
    set name (basename "$target_dir")

    pushd "$target_dir" >/dev/null || return
    twm --path "$target_dir" --name "$name" --command nvim
    popd >/dev/null || return
end
