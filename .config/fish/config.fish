switch_brew (uname -m)

# Configure basher https://github.com/basherpm/basher
if test -d ~/.basher
  set basher ~/.basher/bin
end
set -gx PATH $basher $PATH

if status is-interactive
  # Initialize oh-my-posh
  oh-my-posh init fish --config ~/.config/oh-my-posh/themes/custom.omp.yaml | source

  # Suppress the greeting
  set fish_greeting

  # Initialize basher
  . (basher init - fish | psub)
end

setenv EDITOR micro

# Add some more bin paths to PATH for custom bin scripts
set -gx PATH "$HOME/bin" $PATH
set -gx PATH "$HOME/go/bin" $PATH
set -gx PATH "$HOME/.local/bin" $PATH

alias gr="cd (git rev-parse --show-toplevel)"

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

# pnpm
set -gx PNPM_HOME "/Users/josephschmitt/Library/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

replay "source $HOME/.compassrc"
