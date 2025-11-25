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

  # Every once in a while, a new nix-darwin release may change configuration defaults
  # in a way incompatible with stateful data. For instance, if the default version of
  # PostgreSQL changes, the new version will probably be unable to read your existing
  # databases. To prevent such breakage, you can set the value of this option to the
  # nix-darwin release with which you want to be compatible. The effect is that
  # nix-darwin will option defaults corresponding to the specified release (such as
  # using an older version of PostgreSQL).
  # It should be fine to leave this.
  system.stateVersion = 4; # did you read the comment?
}
