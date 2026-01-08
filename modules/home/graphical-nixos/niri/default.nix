{
  inputs,
  config,
  pkgs,
  ...
}: let
  niriDir = "${config.homeModuleDir}/graphical-nixos/niri";
in {
  imports = [
    inputs.dankMaterialShell.homeModules.niri
  ];

  config = {
    programs.dank-material-shell.niri = {
      enableKeybinds = true;
      enableSpawn = true;
      # https://github.com/AvengeMedia/DankMaterialShell/pull/1239/files
      includes.enable = false;
    };

    programs.niri.package = pkgs.niri;
    stylix.targets.niri.enable = false;

    xdg.portal.xdgOpenUsePortal = true;

    programs.niri.config = null;
    xdg.configFile."niri/config.kdl".source = config.lib.file.mkOutOfStoreSymlink "${niriDir}/config.kdl";
    xdg.configFile."niri/dms-overrides.kdl".source = config.lib.file.mkOutOfStoreSymlink "${niriDir}/dms-overrides.kdl";
    xdg.configFile."niri/dms/alttab.kdl".source = config.lib.file.mkOutOfStoreSymlink "${niriDir}/dms/alttab.kdl";
    xdg.configFile."niri/dms/binds.kdl".source = config.lib.file.mkOutOfStoreSymlink "${niriDir}/dms/binds.kdl";
    xdg.configFile."niri/dms/colors.kdl".source = config.lib.file.mkOutOfStoreSymlink "${niriDir}/dms/colors.kdl";
    xdg.configFile."niri/dms/layout.kdl".source = config.lib.file.mkOutOfStoreSymlink "${niriDir}/dms/layout.kdl";
    xdg.configFile."niri/dms/wpblur.kdl".source = config.lib.file.mkOutOfStoreSymlink "${niriDir}/dms/wpblur.kdl";
  };
}
