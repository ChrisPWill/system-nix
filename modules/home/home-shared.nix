{
  config,
  lib,
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
    isAtlassianMachine = mkEnableOption "Atlassian work machine packages/config";
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

  config = {
    nix.settings.experimental-features = ["nix-command" "flakes"];

    home.sessionPath = ["${config.homeModuleDir}/scripts"];
    programs.nushell.extraEnv = ''
      $env.PATH = ($env.PATH | split row (char esep) | append "${config.homeModuleDir}/scripts")
    '';

    home.stateVersion = "25.05";

    # Can likely remove this later
    # gtk.gtk4.theme = config.gtk.theme;
  };
}
