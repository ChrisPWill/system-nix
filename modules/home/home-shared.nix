{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  # Apps that need sign-off before a locked-down machine may install them:
  # GUI apps, background services, and tools that send data off the machine.
  # Command-line tools that stay local are not gated. nix-darwin modules read
  # the same names, so one list covers both Home Manager and the system.
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
    nixConfigDir = mkOption {
      type = types.str;
      description = "The directory containing the nix configuration";
      default = "${config.home.homeDirectory}/.system-nix";
    };

    homeModuleDir = mkOption {
      type = types.str;
      description = "The directory containing the home module";
      default = "${config.nixConfigDir}/modules/home";
    };

    userEmail = mkOption {
      type = types.str;
      description = "The email address of the user";
      default = "chris@chrispwill.com";
    };

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

    isPersonalMachine = mkEnableOption "personal machine packages/config";
    isWorkMachine = mkEnableOption "work machine packages/config";
    usesDeterminateNix = mkEnableOption "Determinate Nix compatibility";
    hasNvidiaGpu = mkEnableOption "whether the machine has an NVIDIA GPU";

    terminalFontSize = mkOption {
      type = types.int;
      default = 12;
      description = "The font size for the terminal";
    };
  };

  imports = [
    ./core
    ./cli
    ./dev
    ./ops
    ./media
    ./knowledge
    ./desktop
    ./ai
  ];

  config = lib.mkMerge [
    {
      nix.settings.experimental-features = ["nix-command" "flakes"];

      # Resolve `nixpkgs#…` to this flake's locked input rather than the
      # Determinate-provided global entry (nixpkgs-weekly), so ad-hoc
      # `nix run`/`nix shell` see the same package versions the system builds.
      nix.registry.nixpkgs.flake = inputs.nixpkgs;

      home.stateVersion = "25.05";

      # Rofi isn't used, and Stylix's rofi target still sets the renamed
      # programs.rofi.font option, which warns on every build.
      stylix.targets.rofi.enable = false;

      # Can likely remove this later
      # gtk.gtk4.theme = config.gtk.theme;
    }
    (lib.mkIf config.usesDeterminateNix {
      nix.package = pkgs.nix;
    })
  ];
}
