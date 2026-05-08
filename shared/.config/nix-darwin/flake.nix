{
  description = "A flake for my NixOS macOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    # Pin brew to 5.1.10 which fixes the cask_struct_generator nil crash (issue zhaofengli/nix-homebrew#138)
    nix-homebrew.inputs.brew-src.url = "github:Homebrew/brew/5.1.10";
    nix-homebrew.inputs.brew-src.flake = false;
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, ... }:
    let
      lib = nixpkgs.lib;
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

      # Build a darwinSystem from a machine-specific override module.
      mkDarwinSystem = machineModule: nix-darwin.lib.darwinSystem {
        modules = [
          darwinConfig
          machineModule
          nix-homebrew.darwinModules.nix-homebrew
          nixHomebrewConfig
        ];
      };

      # Auto-discover personal machine configs from ./machines/*.nix.
      # Drop a file in `machines/` named after `hostname -s` and it becomes
      # an available darwinConfiguration — no edits to this flake required.
      personalMachineNames = lib.pipe (builtins.readDir ./machines) [
        (lib.filterAttrs (n: t: t == "regular" && lib.hasSuffix ".nix" n))
        builtins.attrNames
        (map (lib.removeSuffix ".nix"))
      ];

      baseConfigs = lib.genAttrs personalMachineNames
        (name: mkDarwinSystem (import (./machines + "/${name}.nix")));

      # Path to work directory (relative to this flake)
      workPath = ../../../work;

      # Helper function to conditionally import work machine configs
      workMachineConfig = name:
        let
          configPath = workPath + "/.config/nix-darwin/machines/${name}.nix";
        in
        if builtins.pathExists configPath
        then import configPath
        else { }; # Empty config if file doesn't exist

      # Work configurations (only if work configs exist)
      workConfigs =
        if builtins.pathExists (workPath + "/.config/nix-darwin/machines")
        then {
          # Compass M1 MacBook Pro
          "W2TD37NJKN" = mkDarwinSystem (workMachineConfig "W2TD37NJKN");

          # Compass M4 MacBook Pro
          "G5FXQQ0D00" = mkDarwinSystem (workMachineConfig "G5FXQQ0D00");
        }
        else { };
    in
    {
      darwinConfigurations = baseConfigs // workConfigs;
    };
}
