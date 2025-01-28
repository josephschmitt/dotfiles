{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    bazel
    bazel-buildtools
    circleci-cli
    colima
    docker
    docker-compose
    gh
    git-spice
    go
    jq
    kubectl
    lima
    shellcheck
    yq
  ];

  homebrew = {
    taps = [
      "UrbanCompass/versions"
    ];

    brews = [
      "hnvm"
    ];
  };

  system.defaults = {
    dock.tilesize = 56;
  };

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}
