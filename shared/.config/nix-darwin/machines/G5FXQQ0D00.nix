{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    bazel
    bazel-buildtools
    bun
    circleci-cli
    colima
    docker
    docker-compose
    gh
    go
    jq
    kubectl
    lima
    mosh
    shellcheck
    yazi

    # Language Servers
    bash-language-server
    docker-compose-language-service
    dockerfile-language-server-nodejs
    fish-lsp
    lua-language-server
    typescript-language-server
    yaml-language-server
    vscode-langservers-extracted
  ];

  homebrew = {
    taps = [
      "UrbanCompass/versions"
    ];

    brews = [
      "hnvm"
      "git-spice"
      "scooter"
    ];

    casks = [
      "betterdisplay"
      "fantastical"
      "notion"
      "Slack"
      "zen"
    ];
  };

  system.defaults = {
    dock.tilesize = 56;
  };

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}
