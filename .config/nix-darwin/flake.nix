{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
  let
    configuration = { pkgs, config, ... }: {
      nixpkgs.config.allowUnfree = true;

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [
          pkgs.fish
          pkgs.fzf
          pkgs.gh
          pkgs.oh-my-posh
          pkgs.stow
          pkgs.neovim
        ];

      environment.shells = [pkgs.fish];

      homebrew = {
        enable = true;
        casks = [
          "1password"
          "arc"
          "iterm2"
          "raycast"
          "setapp"
          "screens-connect"
          "visual-studio-code"
        ];
        onActivation.cleanup = "zap"; # only packages declared here are installed
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };

      system.activationScripts.applications.text = let
        env = pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = "/Applications";
        };
      in
        pkgs.lib.mkForce ''
        # Set up applications.
        echo "setting up /Applications..." >&2
        rm -rf /Applications/Nix\ Apps
        mkdir -p /Applications/Nix\ Apps
        find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
        while read -r src; do
          app_name=$(basename "$src")
          echo "copying $src" >&2
          ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
        done
            '';

      system.defaults = {
        dock.orientation = "left";
        dock.persistent-apps = [
          "/Applications/Arc.app"
          # "/Applications/Sparrow.app"
        ];
        dock.show-process-indicators = true;
        dock.tilesize = 64;
        
        finder.AppleShowAllExtensions = true;
        finder.FXDefaultSearchScope = "SCcf"; # Default search in current folder
        finder.FXPreferredViewStyle = "Nlsv"; # List view
        
        NSGlobalDomain."com.apple.mouse.tapBehavior" = 1; # Enable tap to click
        NSGlobalDomain.AppleKeyboardUIMode = 3; # Enable full keyboard control
        NSGlobalDomain.NSDisableAutomaticTermination = true;
        NSGlobalDomain.NSNavPanelExpandedStateForSaveMode = true;
      };

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#mac-mini
    darwinConfigurations."mac-mini" = nix-darwin.lib.darwinSystem {
      modules = [ 
        configuration 
        nix-homebrew.darwinModules.nix-homebrew
        {
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
        }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."mac-mini".pkgs;
  };
}
