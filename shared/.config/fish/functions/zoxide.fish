function zoxide --wraps=zoxide
    functions -e zoxide z zi
    command zoxide init fish | source
    command zoxide $argv
end

function z --wraps=z
    functions -e zoxide z zi
    command zoxide init fish | source
    z $argv
end

function zi --wraps=zi
    functions -e zoxide z zi
    command zoxide init fish | source
    zi $argv
end
