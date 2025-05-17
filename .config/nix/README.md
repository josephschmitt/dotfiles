# Nix setup on Linux/Ubuntu

## Install

```sh
# First time:
$ nix profile install ~/dotfiles/.config/nix#default

# On later updates:
$ cd ~/dotfiles/.config/nix
$ nix flake update           # refresh nixpkgs revision in flake.lock
$ nix profile upgrade --all  # rebuild your profile to the new lock file
```

## Various Ubuntu things

### Setting default editor in sudo
```sh
$ sudo update-alternatives --install /usr/bin/editor editor $(which nvim) 70
```
* `/usr/bin/editor`: the generic symlink every program (including sudo systemctl edit) consults
* `editor`: the name of the alternatives group
* `/usr/bin/nvim`: the real binary you want to add
* `70`: its priority (higher than nano’s 40 and vim.basic’s 30 so it wins in auto mode)
