# Zoxide lazy-loading wrapper with auto-interactive mode
#
# This file provides custom z/zi functions that:
# 1. Lazy-load zoxide on first use (faster shell startup)
# 2. Automatically trigger interactive mode when z has ambiguous matches
#
# Behavior:
# - z <query>  : Jump directly if 1 match, show picker if multiple matches
# - zi [query] : Always show interactive picker
#
# Example:
# - z dev      : If multiple dirs match "dev", shows fzf picker
# - z dev uc   : If only one match, jumps directly to ~/development/uc-frontend

function z --wraps=z
    functions -e z zi
    command zoxide init fish | source
    
    function z --wraps __zoxide_z
        set -l result_count (zoxide query --list -- $argv 2>/dev/null | count)
        if test $result_count -gt 1
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
        set -l result_count (zoxide query --list -- $argv 2>/dev/null | count)
        if test $result_count -gt 1
            set -l result (zoxide query --interactive -- $argv)
            and cd $result
        else
            __zoxide_z $argv
        end
    end
    
    zi $argv
end
