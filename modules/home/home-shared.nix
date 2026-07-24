{
  config,
  lib,
  pkgs,
  ...
}: {
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

      home.stateVersion = "25.05";

      # Can likely remove this later
      # gtk.gtk4.theme = config.gtk.theme;
    }
    (lib.mkIf config.usesDeterminateNix {
      nix.package = pkgs.nix;
    })
  ];
}
