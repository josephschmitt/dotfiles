function __fish_complete_cdd
  # List only directories within ~/development
  for dir in ~/development/*/
    echo (basename "$dir")
  end
end

complete -c cdd -f -a '(__fish_complete_cdd)'
