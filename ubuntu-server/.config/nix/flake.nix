{
  description = "Package set for my Ubuntu server";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.multica-bin = {
    url = "https://github.com/multica-ai/multica/releases/latest/download/multica_linux_amd64.tar.gz";
    flake = false;
  };

  outputs = { self, nixpkgs, multica-bin }:
    let
      # Your server's architecture.  Change if you're not x86_64.
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      multica = pkgs.stdenv.mkDerivation {
        pname = "multica";
        version = "latest";
        src = multica-bin;
        nativeBuildInputs = [ pkgs.autoPatchelfHook ];
        buildInputs = [ pkgs.stdenv.cc.cc.lib ];
        dontConfigure = true;
        dontBuild = true;
        installPhase = ''
          runHook preInstall
          install -Dm755 multica $out/bin/multica
          runHook postInstall
        '';
        meta = {
          description = "Multica CLI — managed agents platform";
          homepage = "https://github.com/multica-ai/multica";
        };
      };

      tsshd = pkgs.buildGoModule rec {
        pname = "tsshd";
        version = "0.1.6";

        src = pkgs.fetchFromGitHub {
          owner = "trzsz";
          repo = "tsshd";
          rev = "v${version}";
          hash = "sha256-B5PTiz9luBxkDA9UMSkGYTcPbnXdL43rkFvbOUS5F6w=";
        };

        vendorHash = "sha256-dW05EoAVLqmiPRRG0R4KwKsSijZuxSe15iHkyCImtZY=";

        subPackages = [ "cmd/tsshd" ];

        meta = {
          description = "SSH server that supports trzsz file transfer";
          homepage = "https://github.com/trzsz/tsshd";
        };
      };
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
            gnumake
            gum
            lazydocker
            lazygit
            mosh
            neovim
            nil
            nixpkgs-fmt
            nixpkgs-fmt
            nodejs
            oh-my-posh
            ripgrep
            sesh
            stow
            television
            tmux
            uv
            volta
            yq
            zellij
            zoxide
            zsh
            tsshd
            multica
          ];
        };
      };
    };
}
