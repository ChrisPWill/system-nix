{pkgs, ...}: {
  imports = [
    ./dank.nix
    ./niri.nix
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

    # Enable CUPS to print documents.
    services.printing.enable = true;

    services.dbus.enable = true;
    services.upower.enable = true;

    # Enable sound with pipewire.
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;
    };
  };
}
