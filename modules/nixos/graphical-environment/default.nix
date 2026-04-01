{pkgs, ...}: {
  imports = [
    ./dank.nix
    ./niri.nix
    ./kanata.nix
    ../audio.nix
  ];

  config = {
    environment.systemPackages = with pkgs; [
      # Manage monitor layout
      wdisplays

      # Try out vivaldi
      vivaldi
      vivaldi-ffmpeg-codecs

      kdePackages.qtsvg # required by dolphin
      kdePackages.dolphin

      # Needed for xdg portal file picker
      nautilus
    ];

    xdg.portal.enable = true;
    xdg.portal.xdgOpenUsePortal = true;
    xdg.portal.config.common.default = ["gnome" "gtk"];
    xdg.portal.extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
      gnome-keyring
    ];

    services.gnome.gnome-keyring.enable = true;

    # Enable CUPS to print documents.
    services.printing.enable = true;

    services.dbus.enable = true;
    services.upower.enable = true;
  };
}
