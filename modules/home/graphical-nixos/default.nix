{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.dankMaterialShell.homeModules.dankMaterialShell.default

    ./niri
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

    xdg.portal.enable = true;
    xdg.portal.xdgOpenUsePortal = true;
    xdg.portal.config.common.default = ["gnome" "gtk"];
    xdg.portal.extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
      gnome-keyring
    ];

    home.packages = with pkgs; [
      qimgv # quick image viewer
    ];
  };
}
