{inputs, ...}: {
  imports = [
    inputs.self.darwinModules.darwin-shared
    inputs.self.nixosModules.host-shared
  ];

  homebrew = {
    brews = ["awscli"];

    taps = [
      {
        name = "atlassian/lanyard";
        clone_target = "git@bitbucket.org:atlassian/lanyard-tap.git";
      }
    ];

    casks = [
      # AI VSCode wrapper
      "cursor"

      "docker-desktop"

      # For testing Atlassian service calls
      "lanyard"
    ];
  };

  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.cwilliams.home = /Users/cwilliams;

  system.stateVersion = 4;
}
