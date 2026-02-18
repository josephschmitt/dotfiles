{ pkgs, lib, ... }:
let
  tsshd = pkgs.buildGoModule rec {
    pname = "tsshd";
    version = "0.1.6";

    src = pkgs.fetchFromGitHub {
      owner = "trzsz";
      repo = "tsshd";
      rev = "v${version}";
      hash = "sha256-B5PTiz9luBxkDA9UMSkGYTcPbnXdL43rkFvbOUS5F6w=";
    };

    vendorHash = "sha256-dW05EoAVLqmiPRRG0R4KwKsSijZuxSe15iHkyCImtZY=";

    subPackages = [ "cmd/tsshd" ];

    meta = {
      description = "SSH server that supports trzsz file transfer";
      homepage = "https://github.com/trzsz/tsshd";
    };
  };
in
{
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
    tsshd
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
  launchd.user.agents.vibe-kanban = {
    serviceConfig = {
      ProgramArguments = [
        "/opt/homebrew/bin/npx"
        "vibe-kanban"
      ];
      EnvironmentVariables = {
        PORT = "3033";
        HOST = "0.0.0.0";
        PATH = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin";
      };
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/tmp/vibe-kanban.log";
      StandardErrorPath = "/tmp/vibe-kanban.err";
    };
  };

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
