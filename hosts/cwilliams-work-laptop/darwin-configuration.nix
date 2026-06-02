{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  kanataConfig = pkgs.writeText "kanata-global-leader.kbd" config.kanata.globalLeader.config;
  kanataCommand =
    lib.escapeShellArgs
    ([
        "/run/current-system/sw/bin/kanata"
        "--cfg"
        kanataConfig
      ]
      ++ config.kanata.globalLeader.extraArgs);
in {
  imports = [
    # Typical darwin configuration that isn't work or personal specific
    inputs.self.darwinModules.darwin-shared
    # Shared host settings across nixos and darwin
    inputs.self.nixosModules.host-shared
    # Cross-platform Caps Lock global leader configuration
    inputs.self.modules.kanata.global-leader
  ];

  homebrew = {
    brews = [
      "awscli"

      # Used for managing terraform versions. Simpler than nixifying for now
      # https://github.com/tofuutils/tenv
      "tenv"

      # For SignalFM
      "pipx"
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

      # Atlassian's browser
      "thebrowsercompany-dia"
    ];
  };

  environment.systemPackages = [
    pkgs.kanata
  ];

  launchd.daemons.kanata = {
    serviceConfig = {
      ProgramArguments = [
        "/bin/sh"
        "-c"
        "/bin/wait4path /nix/store && exec ${kanataCommand}"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      UserName = "root";
      ProcessType = "Interactive";
      StandardOutPath = "/var/log/kanata.log";
      StandardErrorPath = "/var/log/kanata.log";
    };
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
