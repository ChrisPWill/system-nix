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

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      config.common.default = ["gnome" "gtk"];
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
        gnome-keyring
      ];
    };

    services = {
      gnome.gnome-keyring.enable = true;

      # Enable CUPS to print documents.
      printing.enable = true;

      dbus.enable = true;
      upower.enable = true;
    };

    systemd.services.lock-before-suspend = {
      description = "Lock screen before sleep";
      before = ["sleep.target"];
      wantedBy = ["sleep.target"];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.systemd}/bin/loginctl lock-sessions";
      };
    };
  };
}
