{ pkgs, config, ... }: {
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
      "orbstack"
    ];

    onActivation.cleanup = "zap";
  };

  system.defaults = {
    dock.tilesize = 64;

    dock.persistent-apps = [
      "/Applications/Safari.app"
      "/Applications/ChatGPT.app"
      "/Applications/Ghostty.app"
      "/Applications/Visual Studio Code.app"
    ];
  };

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}
