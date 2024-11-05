if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Suppress the greeting
set fish_greeting

setenv EDITOR micro

# Configure basher https://github.com/basherpm/basher
if test -d ~/.basher
  set basher ~/.basher/bin
end
set -gx PATH $basher $PATH
status --is-interactive; and . (basher init - fish|psub)

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

#
# Compass-specific Config
#

set -x IGNORE_PYTHON_VERSION_REQUIREMENT 1  ##compass5ea843
set -x VIRTUALENVWRAPPER_PYTHON /usr/bin/python2.7  ##compass5ea843
set -x GITROOT /Users/josephschmitt/development  ##compass5ea843

switch_brew (uname -m)
set -gx PATH "$HOME/.jenv/bin" $PATH
# jenv init -
set -x GOPROXY (compass config get artifact-store --name go_proxy)  ##compass5ea843
set -x GONOSUMDB "*"  ##compass5ea843

alias cx="compass"
alias cw="compass workspace"

alias grpcreq="$HOME/development/urbancompass/scripts/grpcreq"

# banyanproxy
fish_add_path /Applications/Banyan.app/Contents/Resources/bin

# pnpm
set -gx PNPM_HOME "/Users/josephschmitt/Library/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

setenv DD_LOGS_INJECTION false
