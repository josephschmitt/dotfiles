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
