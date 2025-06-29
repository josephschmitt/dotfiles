if [ -f $HOME/.bashrc ]; then
  source $HOME/.bash_profile
fi

if [ -f ~/.orbstack/shell/init.zsh ]; then
  # Added by OrbStack: command-line tools and integration
  # This won't be added again if you remove it.
  source ~/.orbstack/shell/init.zsh 2>/dev/null || :
fi
