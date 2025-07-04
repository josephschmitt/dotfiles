{
  description = "A flake for my NixOS macOS configurations";

  inputs = {
    self.submodules = true;
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
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

    # Base configuration set
    baseConfigs = {
      # Personal Mac mini server
      "mac-mini" = nix-darwin.lib.darwinSystem {
        modules = [
          darwinConfig
          (import ./machines/mac-mini.nix)
          nix-homebrew.darwinModules.nix-homebrew
          nixHomebrewConfig
        ];
      };
    };

    # Helper function to conditionally import work machine configs
    workMachineConfig = name: 
      let
        workConfigPath = ../../../work/.config/nix-darwin/machines + "/${name}.nix";
      in
        if builtins.pathExists workConfigPath
        then import workConfigPath
        else { }; # Empty config if work submodule not available

    # Work configurations (only if work submodule exists)
    workConfigs = 
      if builtins.pathExists ../../../work/.config/nix-darwin/machines
      then {
        # Compass M1 MacBook Pro
        "W2TD37NJKN" = nix-darwin.lib.darwinSystem {
          modules = [
            darwinConfig
            (workMachineConfig "W2TD37NJKN")
            nix-homebrew.darwinModules.nix-homebrew
            nixHomebrewConfig
          ];
        };

        # Compass M4 MacBook Pro
        "G5FXQQ0D00" = nix-darwin.lib.darwinSystem {
          modules = [
            darwinConfig
            (workMachineConfig "G5FXQQ0D00")
            nix-homebrew.darwinModules.nix-homebrew
            nixHomebrewConfig
          ];
        };
      }
      else { };
  in
  {
    darwinConfigurations = baseConfigs // workConfigs;
  };
}
