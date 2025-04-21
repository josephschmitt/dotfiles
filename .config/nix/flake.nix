{
  description = "Package set for my Ubuntu server";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
  let
    # Your server’s architecture.  Change if you’re not x86_64.
    system = "x86_64-linux";
    pkgs   = import nixpkgs { inherit system; };
  in {
    # Everything you want to appear on the machine goes in this list ↓
    packages.${system}.default = pkgs.buildEnv {
      name  = "server-env";
      paths = with pkgs; [
        docker
        fd
        fish
        fzf
        gcc
        gh
        git      
        lazygit
        mosh
        neovim
        nodejs
        oh-my-posh
        ripgrep
        stow
        zellij
        zsh
      ];
    };
  };
}
