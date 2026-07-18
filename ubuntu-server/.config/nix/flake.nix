{
  description = "Package set for my Ubuntu server";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  # multica ships as a prebuilt binary per arch — pin one input per system and
  # pick the right tarball below. (Both are updated together by `flake update`.)
  inputs.multica-bin-amd64 = {
    url = "https://github.com/multica-ai/multica/releases/latest/download/multica_linux_amd64.tar.gz";
    flake = false;
  };
  inputs.multica-bin-arm64 = {
    url = "https://github.com/multica-ai/multica/releases/latest/download/multica_linux_arm64.tar.gz";
    flake = false;
  };

  outputs = { self, nixpkgs, multica-bin-amd64, multica-bin-arm64 }:
    let
      # Build for every arch this package set runs on (x86_64 server + arm64 Pi).
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);

      packagesFor = system:
        let
          pkgs = import nixpkgs { inherit system; };

          # Select the multica tarball matching the current architecture.
          multica-bin = {
            "x86_64-linux" = multica-bin-amd64;
            "aarch64-linux" = multica-bin-arm64;
          }.${system};

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
            version = "0.1.8";

            src = pkgs.fetchFromGitHub {
              owner = "trzsz";
              repo = "tsshd";
              rev = "v${version}";
              hash = "sha256-YqSSJA/jP8WRbfwC5fxFE4su01ZEPQNmiNRr96pDE1g=";
            };

            vendorHash = "sha256-HJWxphZuBh3gXPoEqL/EVGtwdWyW+cMSQhKyfSymKG0=";

            subPackages = [ "cmd/tsshd" ];

            meta = {
              description = "SSH server that supports trzsz file transfer";
              homepage = "https://github.com/trzsz/tsshd";
            };
          };

          monocle = pkgs.buildGoModule rec {
            pname = "monocle";
            version = "0.47.0";

            src = pkgs.fetchFromGitHub {
              owner = "josephschmitt";
              repo = "monocle";
              rev = "v${version}";
              hash = "sha256-llXFwyygAR0Et83UGDiWNRh5F+FnaYa0csu/LggNrds=";
            };

            vendorHash = "sha256-oajKuhbP+DRXefoJbrOVoyE1rOdtZaPS4c3u0HUP4Kc=";

            subPackages = [ "cmd/monocle" ];

            # Match GoReleaser's version stamp (-X main.version) so `monocle
            # --version` reports the tag instead of "dev".
            ldflags = [ "-s" "-w" "-X main.version=${version}" ];

            # E2E test spawns a server needing a writable $HOME, unavailable in the
            # Nix build sandbox (HOME=/homeless-shelter).
            doCheck = false;

            meta = {
              description = "monocle-review — terminal code review tool";
              homepage = "https://github.com/josephschmitt/monocle";
            };
          };

          knowledge-tools = pkgs.buildGoModule rec {
            pname = "knowledge-tools";
            version = "0.10.0";

            src = pkgs.fetchFromGitHub {
              owner = "josephschmitt";
              repo = "knowledge-tools";
              # CLI releases are tagged under the cli/ namespace, not bare vX.Y.Z.
              rev = "cli/v${version}";
              hash = "sha256-XbOXYGEsSFF/LuYtI3GjJqVnU3Xodfh9vS+xNZVvjNE=";
            };

            # go.mod lives in the cli/ subdirectory of the monorepo.
            modRoot = "cli";

            vendorHash = "sha256-Ob4MiOsaB81bXAA3Q2CTU20+E1IAtPB2x4i9j52ju9k=";

            subPackages = [ "cmd/knowledge-tools" ];

            # Match GoReleaser's version stamp (-X main.version) so `kt --version`
            # reports the tag instead of "dev".
            ldflags = [ "-s" "-w" "-X main.version=${version}" ];

            # The CLI manages a daemon (fsnotify/cron); its tests need a writable
            # $HOME / spawn processes, unavailable in the Nix build sandbox.
            doCheck = false;

            # GoReleaser's brew formula also installs a `kt` alias; replicate it.
            postInstall = ''
              ln -s knowledge-tools $out/bin/kt
            '';

            meta = {
              description = "knowledge-tools — vault automation CLI (kt)";
              homepage = "https://github.com/josephschmitt/knowledge-tools";
            };
          };
        in
        {
          # Everything you want to appear on the machine goes in this list ↓
          default = pkgs.buildEnv {
            name = "server-env";
            paths = with pkgs; [
              bat
              delta
              devbox
              docker
              eza
              fd
              fish
              fzf
              gcc
              gh
              ghostty
              git
              git-spice
              gnumake
              gofumpt
              gum
              lazydocker
              lazygit
              mosh
              neovim
              nil
              nixpkgs-fmt
              nodejs
              oh-my-posh
              prettierd
              ripgrep
              sesh
              stow
              stylua
              television
              tmux
              uv
              volta
              yq-go
              zellij
              zoxide
              zsh
              tsshd
              multica
              monocle
              knowledge-tools
            ];
          };

          # Custom pins are also exposed individually so `nix build .#<pkg>`
          # works — used by `bin/nix_bump` to derive each vendorHash.
          inherit tsshd multica monocle knowledge-tools;
        };
    in
    {
      packages = forAllSystems packagesFor;
    };
}
