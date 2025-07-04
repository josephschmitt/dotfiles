# Find the given path in zoxide, or enter interactive mode
function zq
    zoxide query "$argv" || zoxide query -i
end
