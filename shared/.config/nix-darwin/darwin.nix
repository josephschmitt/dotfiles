{ pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;

  # Override packages with build issues
  nixpkgs.overlays = [
    (final: prev: {
      # Skip Fish tests - they're flaky on macOS but package works fine
      fish = prev.fish.overrideAttrs (oldAttrs: {
        doCheck = false;
      });

      # Patch foreign-env to skip env vars with invalid Fish names (e.g., TRZSZ-SSHD-BACKGROUND)
      fishPlugins = prev.fishPlugins // {
        foreign-env = prev.fishPlugins.foreign-env.overrideAttrs (oldAttrs: {
          postPatch = (oldAttrs.postPatch or "") + ''
            substituteInPlace functions/fenv.main.fish \
              --replace-fail \
                "string match -rq '^BASH_.*%%\$' \$kv[1]; and continue" \
                "string match -rq '^BASH_.*%%\$' \$kv[1]; and continue
      # Skip variables with names invalid in Fish (e.g., containing hyphens)
      string match -rq '^[a-zA-Z_][a-zA-Z0-9_]*\$' \$kv[1]; or continue"
          '';
        });
      };
    })
  ];

  system.primaryUser = "josephschmitt";

  environment.systemPackages = with pkgs; [
    asdf-vm
    atuin
    bat
    bun
    csvq
    eza
    delta
    fd
    fish
    fzf
    gh
    gum
    lazygit
    neovim
    nil
    nixpkgs-fmt
    nushell
    oh-my-posh
    ripgrep
    sesh
    stow
    tmux
    tree-sitter # Required by nvim-treesitter to compile parsers
    uv
    zellij
    zoxide
  ];

  environment.shells = [ pkgs.fish ];

  homebrew = {
    enable = true;
    brews = [
      "gemini-cli"
      "josephschmitt/tap/pj"
      "raine/workmux/workmux"
      "scooter"
      "television"
    ];
    casks = [
      "1password"
      "adobe-creative-cloud"
      "arc"
      "fantastical"
      "ghostty"
      "hyperkey"
      "leader-key"
      "notion"
      "raycast"
      "setapp"
      "tailscale-app"
      "visual-studio-code"
    ];
    taps = [
      "josephschmitt/tap"
      "raine/workmux"
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
