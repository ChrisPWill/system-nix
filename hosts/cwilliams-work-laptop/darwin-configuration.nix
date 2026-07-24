{inputs, ...}: {
  imports = [
    # Typical darwin configuration that isn't work or personal specific
    inputs.self.darwinModules.darwin-shared
    inputs.self.darwinModules.determinate-nix
    inputs.self.darwinModules.sequence
    # Shared host settings across nixos and darwin
    inputs.self.nixosModules.host-shared
    # Cross-platform Caps Lock global leader configuration
    inputs.self.modules.kanata.global-leader
    # macOS-specific kanata service and dependencies
    inputs.self.modules.darwin.kanata
  ];

  usesDeterminateNix = true;

  nixpkgs.hostPlatform = "aarch64-darwin";
  networking.hostName = "cwilliams-work-laptop";

  users.users.cwilliams.home = /Users/cwilliams;

  system = {
    primaryUser = "cwilliams";

    # Keep the logical layout aligned with the laptop's physical UK keyboard.
    # HIToolbox applies this to the logged-in user's macOS input source.
    defaults.CustomUserPreferences."com.apple.HIToolbox" = let
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
    stateVersion = 4; # did you read the comment?
  };
}
