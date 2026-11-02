{
  config,
  lib,
  ...
}: let
  # Apps that need sign-off before a locked-down machine may install them:
  # GUI apps, background services, and tools that send data off the machine.
  # Command-line tools that stay local are not gated. Home Manager and
  # nix-darwin both import this module, so one set of names covers both.
  gatedApps = [
    "claude-code"
    "cleanshot"
    "colima"
    "element"
    "ffmpeg"
    "ghostty"
    "imageoptim"
    "imagemagick"
    "kanata"
    "lazyjournal"
    "logseq"
    "omniwm"
    "opencode"
    "raycast"
    "scroll-reverser"
    "skhd"
    "sops"
    "spotify"
    "syncthing"
    "t3code"
    "vivaldi"
    "websocat"
    "zathura"
  ];
in {
  options = with lib; {
    approvedApps = mkOption {
      type = types.nullOr (types.listOf (types.enum gatedApps));
      default = null;
      example = ["spotify" "syncthing"];
      description = ''
        Apps a locked-down machine may install. On employer laptops where each
        app needs IT approval, set this to the approved names; gated apps not
        listed are left out. Null approves every gated app.
      '';
    };

    appApproved = mkOption {
      type = types.attrsOf types.bool;
      readOnly = true;
      # Modules read `config.appApproved.<name>` rather than searching the
      # list, so a misspelt name fails evaluation instead of silently gating
      # the app off.
      default = genAttrs gatedApps (name: config.approvedApps == null || elem name config.approvedApps);
      description = "Whether each gated app is approved on this machine. Derived from approvedApps.";
    };
  };
}
