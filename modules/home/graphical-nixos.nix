{
  inputs,
  config,
  ...
}: let
  niriDir = "${config.homeModuleDir}/niri";
in {
  imports = [
    inputs.dankMaterialShell.homeModules.dankMaterialShell.default
    inputs.dankMaterialShell.homeModules.dankMaterialShell.niri
  ];

  config = {
    # Complete desktop shell for Wayland compositors e.g. niri/hyprland
    programs.dankMaterialShell = {
      enable = true;
    };
    # Niri https://yalter.github.io/niri/
    programs.dankMaterialShell.niri = {
      enableKeybinds = true;
      enableSpawn = true;
    };

    programs.niri.config = null;
    xdg.configFile."niri/config.kdl".source = config.lib.file.mkOutOfStoreSymlink "${niriDir}/config.kdl";
    xdg.configFile."niri/dms/alttab.kdl".source = config.lib.file.mkOutOfStoreSymlink "${niriDir}/alttab.kdl";
    xdg.configFile."niri/dms/colors.kdl".source = config.lib.file.mkOutOfStoreSymlink "${niriDir}/alttab.kdl";
    xdg.configFile."niri/dms/layout.kdl".source = config.lib.file.mkOutOfStoreSymlink "${niriDir}/alttab.kdl";
    xdg.configFile."niri/dms/wpblur.kdl".source = config.lib.file.mkOutOfStoreSymlink "${niriDir}/alttab.kdl";
  };
}
