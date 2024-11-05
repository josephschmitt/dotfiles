
function __complete_compass
    set -lx COMP_LINE (commandline -cp)
    test -z (commandline -ct)
    and set COMP_LINE "$COMP_LINE "
    /usr/local/bin/compass
end
complete -f -c compass -a "(__complete_compass)"

