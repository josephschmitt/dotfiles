function twmp
    pushd >/dev/null || exit
    if test -z "$argv"
        twm --path (zq "$PWD")
    else
        twm --path (zq "$argv")
    end
    popd >/dev/null || exit
end
