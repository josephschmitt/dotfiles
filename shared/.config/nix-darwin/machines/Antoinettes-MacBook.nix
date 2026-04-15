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
    git
    gum
    nodejs
    pnpm
    rustup
    tsshd
  ];

  homebrew = {
    brews = [];

    casks = [
      "claude"
      "jump-desktop-connect"
    ];

    taps = [];

    onActivation.cleanup = "zap";
  };

  system.defaults = {
    dock.tilesize = 64;
  };

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}
