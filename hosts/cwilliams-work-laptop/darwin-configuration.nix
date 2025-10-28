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
      "cloudtoken"

      # AI VSCode wrapper
      "cursor"

      "docker-desktop"

      "google-drive"

      # For testing Atlassian service calls
      "lanyard"
    ];
  };

  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.cwilliams.home = /Users/cwilliams;
  system.primaryUser = "cwilliams";

  system.stateVersion = 4;
}
