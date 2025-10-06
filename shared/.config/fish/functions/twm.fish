function twm --wraps=twm
    functions -e twm
    command twm --print-fish-completion | source
    command twm $argv
end
