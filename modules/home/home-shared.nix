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
  };

  imports = [
    ./core
    ./dev
    ./ops
    ./media
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
  };
}
