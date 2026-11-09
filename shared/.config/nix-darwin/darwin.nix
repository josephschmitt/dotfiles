{ config, lib, pkgs, ... }: {
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
    bat
    bun
    csvq
    delta
    eza
    fd
    fish
    fzf
    gh
    git
    gofumpt
    gum
    jq
    lazygit
    neovim
    nil
    nixpkgs-fmt
    oh-my-posh
    prettierd
    ripgrep
    sesh
    stow
    stylua
    terminal-notifier
    tmux
    tree-sitter # Required by nvim-treesitter to compile parsers
    uv
    yq-go
    zoxide
  ];

  environment.shells = [ pkgs.fish ];

  # Homebrew resolves its user config dir (and therefore the `brew trust` store)
  # from $XDG_CONFIG_HOME. The nix-darwin homebrew module runs `brew bundle` via
  # `sudo --preserve-env=PATH`, which strips XDG_CONFIG_HOME, so activation falls
  # back to ~/.homebrew/trust.json while interactive `brew trust` writes to
  # ~/.config/homebrew/trust.json. The two stores diverge and every non-official
  # tap reads as untrusted during activation.
  #
  # /etc/homebrew/brew.env is read by bin/brew itself (before it computes
  # HOMEBREW_USER_CONFIG_HOME), so it survives sudo's env_reset.
  # HOMEBREW_XDG_CONFIG_HOME is the documented fallback used when XDG_CONFIG_HOME
  # is unset, which pins both contexts to the same trust store.
  environment.etc."homebrew/brew.env".text = ''
    HOMEBREW_XDG_CONFIG_HOME=/Users/${config.system.primaryUser}/.config
  '';

  # Declaratively `brew trust` every non-official tap this config uses: each
  # entry in homebrew.taps plus the tap prefix of any fully-qualified brew/cask
  # ("owner/tap/name"). Listing a tap here *is* the decision to trust it, so
  # there's no separate `brew trust` step to forget.
  #
  # Taps are merged into trust.json, never removed: when a tap is dropped from
  # the config, `brew bundle --zap` cleanup still has to load its formulae to
  # uninstall them, which fails if the tap is no longer trusted. Manual
  # `brew trust` entries are preserved too. Runs in preActivation, well before
  # the Homebrew bundle step.
  system.activationScripts.preActivation.text =
    let
      nameOf = x: if builtins.isString x then x else x.name;
      tapOf =
        n:
        let
          parts = lib.splitString "/" n;
        in
        lib.optional (builtins.length parts == 3) "${builtins.elemAt parts 0}/${builtins.elemAt parts 1}";
      hb = config.homebrew;
      taps = lib.unique (
        map (t: lib.toLower (nameOf t)) hb.taps
        ++ map lib.toLower (lib.concatMap (x: tapOf (nameOf x)) (hb.brews ++ hb.casks))
      );
      user = config.system.primaryUser;
      trustTaps = pkgs.writeShellScript "brew-trust-taps" ''
        set -eu
        f="/Users/${user}/.config/homebrew/trust.json"
        mkdir -p "$(dirname "$f")"
        [ -s "$f" ] || echo '{}' > "$f"
        tmp="$(mktemp "$f.XXXXXX")"
        ${pkgs.jq}/bin/jq --argjson t '${builtins.toJSON taps}' \
          '.trustedtaps = (((.trustedtaps // []) + $t) | unique)' "$f" > "$tmp"
        mv "$tmp" "$f"
      '';
    in
    lib.mkIf hb.enable ''
      echo >&2 "trusting Homebrew taps..."
      sudo --user=${user} --set-home ${trustTaps} || echo >&2 "warning: failed to update Homebrew trust.json"
    '';

  homebrew = {
    enable = true;
    brews = [
      "herdr"
      "josephschmitt/tap/pj"
      "scooter"
      "television"
      "worktrunk"
    ];
    casks = [
      "1password"
      "adobe-creative-cloud"
      "arc"
      "fantastical"
      "ghostty"
      "hyperkey"
      "josephschmitt/tap/monocle"
      "leader-key"
      "notion"
      "raycast"
      "setapp"
      "tailscale-app"
      "veil-default-editor"
      "visual-studio-code"
    ];
    taps = [
      "0x1b2c/veil"
      "josephschmitt/tap"
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
