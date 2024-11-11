if [ -f $HOME/.bashrc ]; then
  source $HOME/.bashrc
fi

if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
  eval "$(oh-my-posh init zsh --config $HOME/.config/oh-my-posh/themes/catppuccin_frappe.omp.yaml)"
fi
