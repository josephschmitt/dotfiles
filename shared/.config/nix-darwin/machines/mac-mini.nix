{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    git
    lf
    mosh
    nodejs
    pnpm
    rustup
  ];

  homebrew = {
    casks = [
      "backblaze"
      "jump-desktop-connect"
      "lm-studio"
      "orbstack"
    ];

    onActivation.cleanup = "zap";
  };

  system.defaults = {
    dock.tilesize = 64;
  };

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}
