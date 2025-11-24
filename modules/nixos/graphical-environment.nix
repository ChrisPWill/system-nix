{...}: {
  # Enable the GNOME Desktop Environment.
  # Enable the X11 windowing system.
  services.xserver.enable = false;
  services.displayManager.gdm.enable = false;
  services.desktopManager.gnome.enable = false;

  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

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

  # Install firefox.
  programs.firefox.enable = true;
}
