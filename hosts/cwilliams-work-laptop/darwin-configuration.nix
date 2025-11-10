{inputs, ...}: {
  imports = [
    inputs.self.darwinModules.darwin-shared
    inputs.self.nixosModules.host-shared
  ];

  homebrew = {
    brews = [
      "awscli"

      # Used for managing terraform versions. Simpler than nixifying for now
      # https://github.com/tofuutils/tenv
      "tenv"
    ];

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

      # Test requests
      "insomnia"

      # For testing Atlassian service calls
      "lanyard"

      # Screen recordings
      "loom"

      # Music
      "spotify"
    ];
  };

  nixpkgs.hostPlatform = "aarch64-darwin";
  networking.hostName = "cwilliams-work-laptop";

  users.users.cwilliams.home = /Users/cwilliams;
  system.primaryUser = "cwilliams";

  system.stateVersion = 4;
}
