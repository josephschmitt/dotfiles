{ pkgs, config, ... }: {
  environment.systemPackages = [
    pkgs.bun
    pkgs.mosh
    pkgs.nodejs
    pkgs.pnpm
  ];

  homebrew = {
    casks = [
      "backblaze"
      "orbstack"
      "tailscale"
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
      joe-sh-docker-compose = {
        command = "${pkgs.docker-compose}/bin/docker-compose up -d";
        serviceConfig = {
          KeepAlive = false;
          RunAtLoad = true;
          StandardOutPath = "/tmp/docker-compose.out";
          StandardErrorPath = "/tmp/docker-compose.err";
          WorkingDirectory = "/Volumes/Docker/joe.sh";
        };
      };
      finergifs-docker-compose = {
        command = "${pkgs.docker-compose}/bin/docker-compose --env-file .env.prod up --build -d";
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
