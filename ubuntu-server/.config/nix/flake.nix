{
  description = "Package set for my Ubuntu server";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      # Your server’s architecture.  Change if you’re not x86_64.
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      packages.${system} = {
        # Everything you want to appear on the machine goes in this list ↓
        default = pkgs.buildEnv {
          name = "server-env";
          paths = with pkgs; [
            bat
            delta
            docker
            eza
            fd
            fish
            fzf
            gcc
            gh
            ghostty
            git
            gum
            lazygit
            mosh
            neovim
            nil
            nixpkgs-fmt
            nixpkgs-fmt
            oh-my-posh
            opencode
            ripgrep
            sesh
            stow
            tmux
            twm
            uv
            volta
            zellij
            zoxide
            zsh
          ];
        };
      };
    };
}
