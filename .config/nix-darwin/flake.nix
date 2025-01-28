{
  description = "A flake for my NixOS macOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    nix-direnv.url = "github:nix-community/nix-direnv";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, nix-direnv }:
  let
    darwinConfig = import ./darwin.nix;
    nixHomebrewConfig = {
      nix-homebrew = {
        # Install Homebrew under the default prefix
        enable = true;

        # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
        # enableRosetta = true;

        # User owning the Homebrew prefix
        user = "josephschmitt";

        # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
        # mutableTaps = false;
      };
    };
  in
  {
    darwinConfigurations = {
      # Personal Mac mini server
      "mac-mini" = nix-darwin.lib.darwinSystem {
        modules = [
          darwinConfig
          (import ./machines/mac-mini.nix)
          nix-homebrew.darwinModules.nix-homebrew
          nixHomebrewConfig
        ];
      };

      # Compass M1 MacBook Pro
      "W2TD37NJKN" = nix-darwin.lib.darwinSystem {
        modules = [
          darwinConfig
          (import ./machines/W2TD37NJKN.nix)
          nix-homebrew.darwinModules.nix-homebrew
          nixHomebrewConfig
        ];
      };
    };
  };
}
