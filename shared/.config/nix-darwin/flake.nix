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

      # --- Private profile machine configs (submodules: work, rca, etc.) ---
      # Each private profile lives at ../../../<name> relative to this flake.
      # Machine hostnames must be listed explicitly (unlike personal machines
      # which are auto-discovered) because the submodule may not be initialised.

      mkPrivateProfileConfig = profile: hostname:
        let
          profilePath = ../../../${profile};
          configPath = profilePath + "/.config/nix-darwin/machines/${hostname}.nix";
        in
        if builtins.pathExists configPath
        then import configPath
        else { };

      mkPrivateProfileConfigs = profile: hostnames:
        let
          profilePath = ../../../${profile};
        in
        if builtins.pathExists (profilePath + "/.config/nix-darwin/machines")
        then lib.genAttrs hostnames (name: mkDarwinSystem (mkPrivateProfileConfig profile name))
        else { };

      privateProfileConfigs = { }
        // mkPrivateProfileConfigs "work" [
          "W2TD37NJKN"  # Compass M1 MacBook Pro
          "G5FXQQ0D00"  # Compass M4 MacBook Pro
        ]
        // mkPrivateProfileConfigs "rca" [
          # Add RCA machine hostnames here as they are provisioned
        ];
    in
    {
      darwinConfigurations = baseConfigs // privateProfileConfigs;
    };
}
