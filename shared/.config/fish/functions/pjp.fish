function pjp
    set tmp (mktemp)
    # tv renders TUI to stdout when it's a tty; use a pty via `script` so tv thinks
    # stdout is a terminal, then extract the last non-empty line as the selection
    script -q /dev/null tv pj > $tmp
    set dir (string trim (tail -1 $tmp))
    rm $tmp
    test -n "$dir" && cd $dir
end
