{
  inputs,
  config,
  pkgs,
  ...
}: let
  niriDir = "${config.homeModuleDir}/graphical-nixos/niri";
in {
  imports = [
    inputs.dankMaterialShell.homeModules.dankMaterialShell.default
    inputs.dankMaterialShell.homeModules.dankMaterialShell.niri

    ./default-apps.nix
  ];

  config = {
    # Complete desktop shell for Wayland compositors e.g. niri/hyprland
    programs.dankMaterialShell = {
      enable = true;

      systemd = {
        enable = true;
        restartIfChanged = true;
      };
    };
    # Niri https://yalter.github.io/niri/
    programs.dankMaterialShell.niri = {
      enableKeybinds = true;
      enableSpawn = true;
    };

    programs.niri.config = null;
    programs.niri.package = pkgs.niri;

    xdg.portal.enable = true;
    xdg.portal.xdgOpenUsePortal = true;
    xdg.portal.config.common.default = ["termfilechooser" "gnome" "gtk"];
    xdg.portal.extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
      xdg-desktop-portal-termfilechooser
      gnome-keyring
    ];

    xdg.configFile."niri/config.kdl".source = config.lib.file.mkOutOfStoreSymlink "${niriDir}/config.kdl";
    xdg.configFile."niri/dms-overrides.kdl".source = config.lib.file.mkOutOfStoreSymlink "${niriDir}/dms-overrides.kdl";
    xdg.configFile."niri/dms/alttab.kdl".source = config.lib.file.mkOutOfStoreSymlink "${niriDir}/dms/alttab.kdl";
    xdg.configFile."niri/dms/binds.kdl".source = config.lib.file.mkOutOfStoreSymlink "${niriDir}/dms/binds.kdl";
    xdg.configFile."niri/dms/colors.kdl".source = config.lib.file.mkOutOfStoreSymlink "${niriDir}/dms/colors.kdl";
    xdg.configFile."niri/dms/layout.kdl".source = config.lib.file.mkOutOfStoreSymlink "${niriDir}/dms/layout.kdl";
    xdg.configFile."niri/dms/wpblur.kdl".source = config.lib.file.mkOutOfStoreSymlink "${niriDir}/dms/wpblur.kdl";
  };
}
