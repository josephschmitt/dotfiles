{ pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;
  system.primaryUser = "josephschmitt";

  environment.systemPackages = with pkgs; [
    asdf-vm 
    atuin
    bat
    bun
    csvq
    delta
    fd
    fish
    fzf
    gh
    gum
    lazygit
    neovim
    oh-my-posh
    ripgrep
    sesh
    stow
    tmux
    twm
    zellij
    zoxide
  ];

  environment.shells = [pkgs.fish];

  homebrew = {
    enable = true;
    brews = [
      "helix"
      "morantron/tmux-fingers/tmux-fingers"
      "sst/tap/opencode"
    ];
    casks = [
      "1password"
      "adobe-creative-cloud"
      "arc"
      "chatgpt"
      "claude"
      "ghostty"
      "hyperkey"
      "leader-key"
      "raycast"
      "runjs"
      "setapp"
      "tailscale-app"
      "visual-studio-code"
      "vimr"
    ];
    taps = [
      "sst/tap"
      "morantron/tmux-fingers"
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
    pkgs.nerd-fonts.fira-code
  ];

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
