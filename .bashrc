if [ -f "$HOME/.compassrc" ]; then
  source "$HOME/.compassrc"
fi

# Configure bash shell if we're in bash
if [[ "$(ps -p $$ -o comm=)" = *"bash"* ]]; then
  eval "$(oh-my-posh init bash --config ~/.config/oh-my-posh/themes/custom.omp.yaml)"

  # Setup basher
  export PATH="$HOME/.basher/bin:$PATH"
  eval "$(basher init - bash)" # replace `bash` with `zsh` if you use zsh
fi

complete -C /usr/local/bin/compass compass

export EDITOR="nvim"
export OPENAI_API_KEY="op://Private/OPENAI_API_KEY/credential"

# Add more bin paths to PATH for custom bin scripts
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/development/zide/bin:$PATH"
export PATH="$HOME/development/zj/bin:$PATH"

# Configure asdf
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# Add some common aliases
alias groot="echo 'I am Groot!' && cd \$(git rev-parse --show-toplevel)"
alias darwin_rebuild="darwin-rebuild switch --flake ~/dotfiles/.config/nix-darwin"
alias darwin_update="nix flake update --flake ~/dotfiles/.config/nix-darwin"
alias nix_rebuild="nix profile upgrade --all"
alias nix_update="nix flake update --flake ~/dotfiles/.config/nix"

alias lg="lazygit"

# Git-spice aliases
alias gsb="gs branch"
alias gsbc="gs branch checkout"
alias gsbcr="gs branch create"
alias gsbs="gs branch submit"
alias gsbt="gs branch track"

alias gsc="gs commit"
alias gsca="gs commit amend"
alias gscc="gs commit commit"

alias gsl="gs log long -a"
alias gsll="gs log long"
alias gsls="gs log short"

alias gsr="gs repo"
alias gsrs="gs repo sync"

alias gss="gs stack"
alias gssr="gs stack restack"
alias gsss="gs stack submit"
