{ pkgs, config, ... }: {
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = [
    pkgs.fd
    pkgs.fish
    pkgs.fzf
    pkgs.gh
    pkgs.helix
    pkgs.lazygit
    pkgs.neovim
    pkgs.oh-my-posh
    pkgs.stow
    pkgs.tmux
    pkgs.zellij
    pkgs.yazi
  ];

  environment.shells = [pkgs.fish];

  homebrew = {
    enable = true;
    casks = [
      "1password"
      "adobe-creative-cloud"
      "chatgpt"
      "hyperkey"
      "iterm2"
      "logi-options+"
      "raycast"
      "setapp"
      "tailscale"
      "visual-studio-code"
    ];

    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
  };

  system.defaults = {
    dock.orientation = "left";
    dock.show-process-indicators = true;

    finder.AppleShowAllExtensions = true;
    finder.FXDefaultSearchScope = "SCcf"; # Default search in current folder
    finder.FXPreferredViewStyle = "Nlsv"; # List view

    NSGlobalDomain."com.apple.mouse.tapBehavior" = 1; # Enable tap to click
    NSGlobalDomain.AppleKeyboardUIMode = 3; # Enable full keyboard control
    NSGlobalDomain.NSDisableAutomaticTermination = true;
    NSGlobalDomain.NSNavPanelExpandedStateForSaveMode = true;
    NSGlobalDomain."com.apple.sound.beep.volume" = 0.0; # Disable system beep

    CustomUserPreferences = {
      "com.microsoft.VSCode" = {
        ApplePressAndHoldEnabled = false; # Enable key repeating
      };

      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true; # Don't create .DS_Store files on network drives
      };
    };
  };

  fonts.packages = [
    pkgs.nerd-fonts.meslo-lg
  ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Enable alternative shell support in nix-darwin.
  programs.fish.enable = true;

  # Set Git commit hash for darwin-version.
  system.configurationRevision = null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;
}
