# Not used until admin rights allow nix-darwin. Home Manager stays standalone
# (users/cwilliams82.nix) even then, so it can switch without sudo. See
# README.md.
{
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.self.darwinModules.darwin-shared
    inputs.self.darwinModules.determinate-nix
    inputs.self.nixosModules.host-shared
    # Both stay inert until "kanata" is in approvedApps.
    inputs.self.modules.kanata.global-leader
    inputs.self.modules.darwin.kanata
  ];

  usesDeterminateNix = true;

  # Intuit's network intercepts HTTPS through Zscaler.
  keychainCaBundle.enable = true;

  approvedApps = import ./approved-apps.nix;

  # Blueprint would run users/cwilliams82.nix through nix-darwin, which makes
  # every Home Manager switch need sudo. That file is switched on its own
  # instead.
  home-manager.users = lib.mkForce {};

  nixpkgs.hostPlatform = "aarch64-darwin";
  # networking.hostName is left unset: IT names this machine, and `sw` finds
  # this config through dev.nix.flakeHostName instead.

  # IT may install its own tools with Homebrew. "uninstall" would remove
  # anything not declared here on every switch.
  homebrew.onActivation.cleanup = lib.mkForce "none";

  users.users.cwilliams82.home = /Users/cwilliams82;

  system = {
    primaryUser = "cwilliams82";

    # Keep the logical layout aligned with the laptop's physical UK keyboard.
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

    # Set once at first install; don't change it afterwards.
    stateVersion = 6;
  };
}
