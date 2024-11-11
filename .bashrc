if [ -f $HOME/.compassrc ]; then
  source $HOME/.compassrc
fi

# Configure bash shell if we're in bash
if [[ "$(ps -p $$ -o comm=)" = *"bash"* ]]; then
  eval "$(oh-my-posh init bash --config ~/.config/oh-my-posh/themes/catppuccin_frappe.omp.yaml)"

  # Setup basher
  export PATH="$HOME/.basher/bin:$PATH"
  eval "$(basher init - bash)" # replace `bash` with `zsh` if you use zsh
fi

# This function is for use on Macs with multiple brew installations (usually M1/arm64) Macs. This
# function will attempt to set your brew PATH to point to the correct brew based on the system arch.
#
# Usage:
#   # will automatically set brew based on architecture
#   $ switch_brew
#
#   # will set brew for arm64
#   $ switch_brew arm64
#
#   # will set brew for x86_64
#   $ switch_brew x86_64
function switch_brew {
  armBrewPath="/opt/homebrew/bin"
  switch_to=${1:-"$(uname -m)"}

  if [ "${switch_to}" = "arm64" ]; then
    PATH="${armBrewPath}:$PATH"
  else
    PATH=${PATH/":$armBrewPath"/} # delete any instances in the middle or at the end
    PATH=${PATH/"$armBrewPath:"/} # delete any instances at the beginning
  fi
}

switch_brew
complete -C /usr/local/bin/compass compass

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
