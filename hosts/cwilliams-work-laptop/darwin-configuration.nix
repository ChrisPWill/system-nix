{
  config,
  inputs,
  pkgs,
  lib,
  ...
}: let
  primaryUser = config.system.primaryUser;
  primaryUserHome = "/Users/${primaryUser}";
  omniwmLaunchScript = pkgs.writeShellScript "launch-omniwm-after-kanata" ''
    /bin/wait4path /nix/store

    attempts=0
    while [ "$attempts" -lt 75 ]; do
      if /bin/launchctl print system/org.nixos.kanata 2>/dev/null | /usr/bin/grep -q "state = running"; then
        break
      fi

      attempts=$((attempts + 1))
      /bin/sleep 0.2
    done

    /bin/sleep 1
    exec /usr/bin/open -a OmniWM
  '';
in {
  imports = [
    # Typical darwin configuration that isn't work or personal specific
    inputs.self.darwinModules.darwin-shared
    inputs.self.darwinModules.sequence
    # Shared host settings across nixos and darwin
    inputs.self.nixosModules.host-shared
    # Cross-platform Caps Lock global leader configuration
    inputs.self.modules.kanata.global-leader
    # macOS-specific kanata service and dependencies
    inputs.self.modules.darwin.kanata
  ];

  # Temporary hack until I figure out a better solution to det nix
  nix = {
    enable = false;
    gc = {automatic = lib.mkForce false;};
    optimise = {automatic = lib.mkForce false;};
    package = pkgs.nix;
  };
  # End hack

  homebrew = {
    casks = [
      "cleanshot"

      # AI VSCode wrapper
      "cursor"

      # Added as a brew cask to get latest updates
      "claude-code"

      "datagrip"

      "docker-desktop"

      "gcloud-cli"
      "google-drive"

      # AI note taker
      "granola"

      # Test requests
      "insomnia"

      "intellij-idea"

      # Reduce image sizes
      "imageoptim"

      # Screen recordings
      "loom"

      # Test APIs etc.
      "rapidapi"

      # DB management
      "tableplus"

      "vivaldi"
    ];
  };

  environment.systemPackages = [
  ];

  launchd.user.agents.omniwm = {
    serviceConfig = {
      ProgramArguments = [
        "${omniwmLaunchScript}"
      ];
      RunAtLoad = true;
      KeepAlive = false;
      LimitLoadToSessionType = "Aqua";
      ProcessType = "Interactive";
      StandardOutPath = "${primaryUserHome}/Library/Logs/omniwm.launchd.log";
      StandardErrorPath = "${primaryUserHome}/Library/Logs/omniwm.launchd.log";
    };
  };

  nixpkgs.hostPlatform = "aarch64-darwin";
  networking.hostName = "cwilliams-work-laptop";

  users.users.cwilliams.home = /Users/cwilliams;
  system.primaryUser = "cwilliams";

  # Keep the logical layout aligned with the laptop's physical UK keyboard.
  # HIToolbox applies this to the logged-in user's macOS input source.
  system.defaults.CustomUserPreferences."com.apple.HIToolbox" = let
    britishKeyboard = {
      InputSourceKind = "Keyboard Layout";
      "KeyboardLayout ID" = 2;
      "KeyboardLayout Name" = "British";
    };
  in {
    AppleCurrentKeyboardLayoutInputSourceID = "com.apple.keylayout.British";
    AppleEnabledInputSources = [britishKeyboard];
    AppleSelectedInputSources = [britishKeyboard];
  };

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
