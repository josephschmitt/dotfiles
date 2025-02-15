{ pkgs, config, ... }: {
  environment.systemPackages = with pkgs; [
    broot
    bun
    git
    lf
    mosh
    (nnn.override { withNerdIcons = true; })
    nodejs
    pnpm
    rustup
    smartmontools
  ];

  homebrew = {
    casks = [
      "backblaze"
      "orbstack"
    ];

    onActivation.cleanup = "zap";
  };

  # Add a launchd agent to start docker-compose on boot
  launchd = {
    daemons = {
      hbojoe-docker-compose = {
        command = "${pkgs.docker-compose}/bin/docker-compose up -d";
        serviceConfig = {
          KeepAlive = false;
          RunAtLoad = true;
          StandardOutPath = "/tmp/docker-compose.out";
          StandardErrorPath = "/tmp/docker-compose.err";
          WorkingDirectory = "/Volumes/Docker/hbojoe";
        };
      };
    };
  };

  system.defaults = {
    dock.tilesize = 64;

    dock.persistent-apps = [
      "/Applications/Safari.app"
      "/Applications/ChatGPT.app"
      "/Applications/iTerm.app"
      "/Applications/Visual Studio Code.app"
    ];
  };

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}
