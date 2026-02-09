{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    devbox
    direnv
    git
    gum
    lf
    mosh
    nodejs
    pnpm
    rustup
  ];

  homebrew = {
    brews = [
      "immich-cli"
      "osxphotos"
    ];

    casks = [
      "backblaze"
      "chatgpt"
      "claude"
      "jump-desktop-connect"
      "lm-studio"
      "orbstack"
    ];

    onActivation.cleanup = "zap";
  };

  system.defaults = {
    dock.tilesize = 64;
  };

  # LaunchAgents for automated tasks
  launchd.user.agents.immich-sync = {
    serviceConfig = {
      ProgramArguments = [
        "${pkgs.bash}/bin/bash"
        "/Users/josephschmitt/bin/immich-sync"
      ];
      StartCalendarInterval = [
        {
          Hour = 2;
          Minute = 0;
        }
      ];
      StandardErrorPath = "/Users/josephschmitt/Library/Logs/immich-sync/launchd-error.log";
      StandardOutPath = "/Users/josephschmitt/Library/Logs/immich-sync/launchd-output.log";
      EnvironmentVariables = {
        PATH = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin";
      };
      RunAtLoad = false;
      ProcessType = "Background";
    };
  };

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}
