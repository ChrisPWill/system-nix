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
      {
        name = "atlassian/cloudtoken";
        clone_target = "git@bitbucket.org:atlassian/cloudtoken-homebrew-tap.git";
        force_auto_update = true;
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

      # Screen recordings
      "loom"
    ];
  };

  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.cwilliams.home = /Users/cwilliams;
  system.primaryUser = "cwilliams";

  system.stateVersion = 4;
}
