{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.bazel
    pkgs.circleci-cli
    pkgs.colima
    pkgs.docker
    pkgs.docker-compose
    pkgs.gh
    pkgs.git-spice
    pkgs.go
    pkgs.jq
    pkgs.kubectl
    pkgs.lima
    pkgs.shellcheck
    pkgs.yq
  ];

  homebrew = {
    taps = [
      "UrbanCompass/versions"
    ];

    brews = [
      "hnvm"
    ];
  };

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}
