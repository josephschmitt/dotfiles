# Nix Darwin Config

## Installation Instructions
1. Install [`nix`](https://nixos.org/download/) if not already installed
```
$ sh <(curl -L https://nixos.org/nix/install)
```

2. Install [`nix-darwin`](https://github.com/LnL7/nix-darwin) using `nix`
```
$ nix run nix-darwin -- switch --flake ~/dotfiles/.config/nix-darwin
```

3. Apply nix-darwin
```
$ darwin-rebuild switch --flake ~/.config/nix-darwin
```

## Usage
Make changes to [`flake.nix`](./flake.nix), and then apply in `nix-darwin`:
```
$ darwin-rebuild switch --flake ~/.config/nix-darwin
```

To upgrade package dependencies,
```
$ nix flake update
$ darwin-rebuild switch --flake ~/.config/nix-darwin
```
