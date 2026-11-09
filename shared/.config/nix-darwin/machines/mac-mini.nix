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
    gum
    lf
    mosh
    nodejs
    nut
    pnpm
    rustup
    tsshd
  ];

  homebrew = {
    brews = [
      "immich-cli"
      "multica-ai/tap/multica"
      "rhettbull/osxphotos/osxphotos"
    ];

    casks = [
      "backblaze"
      "chatgpt"
      "claude"
      "jump-desktop-connect"
      "orbstack"
    ];

    taps = [
      { name = "multica-ai/tap"; trusted = true; }
      { name = "rhettbull/osxphotos"; trusted = true; }
    ];

    onActivation.cleanup = "zap";
  };

  system.defaults = {
    dock.tilesize = 64;
  };

  # LaunchAgents for automated tasks
  launchd.user.agents.cyrus = {
    serviceConfig = {
      ProgramArguments = [
        "/opt/homebrew/bin/cyrus"
      ];
      EnvironmentVariables = {
        PATH = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin";
      };
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/tmp/cyrus.log";
      StandardErrorPath = "/tmp/cyrus.err";
    };
  };

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}
