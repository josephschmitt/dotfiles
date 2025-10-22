function basher --wraps=basher --description 'Lazy-load basher package manager'
    functions -e basher
    command basher init - fish | source
    command basher $argv
end
