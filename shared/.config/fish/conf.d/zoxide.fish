# Zoxide lazy-loading wrapper with auto-interactive mode
#
# This file provides custom z/zi functions that:
# 1. Lazy-load zoxide on first use (faster shell startup)
# 2. Automatically trigger interactive mode when z has ambiguous matches
#
# Environment variables:
# - ZOXIDE_INTERACTIVE_THRESHOLD: Minimum number of matches to trigger interactive mode (default: 2)
#
# Behavior:
# - z <query>  : Jump directly if below threshold, show picker if >= threshold matches
# - zi [query] : Always show interactive picker
#
# Example:
# - z dev      : If multiple dirs match "dev", shows fzf picker
# - z dev uc   : If only one match, jumps directly to ~/development/uc-frontend
# - ZOXIDE_INTERACTIVE_THRESHOLD=3 : Require 3+ matches before triggering picker

function z --wraps=z
    functions -e z zi
    command zoxide init fish | source
    
    function z --wraps __zoxide_z
        set -l threshold (test -n "$ZOXIDE_INTERACTIVE_THRESHOLD"; and echo $ZOXIDE_INTERACTIVE_THRESHOLD; or echo 2)
        set -l result_count (zoxide query --list -- $argv 2>/dev/null | count)
        if test $result_count -ge $threshold
            set -l result (zoxide query --interactive -- $argv)
            and cd $result
        else
            __zoxide_z $argv
        end
    end
    
    z $argv
end

function zi --wraps=zi
    functions -e z zi
    command zoxide init fish | source
    
    function z --wraps __zoxide_z
        set -l threshold (test -n "$ZOXIDE_INTERACTIVE_THRESHOLD"; and echo $ZOXIDE_INTERACTIVE_THRESHOLD; or echo 2)
        set -l result_count (zoxide query --list -- $argv 2>/dev/null | count)
        if test $result_count -ge $threshold
            set -l result (zoxide query --interactive -- $argv)
            and cd $result
        else
            __zoxide_z $argv
        end
    end
    
    zi $argv
end
