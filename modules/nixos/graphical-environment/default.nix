{pkgs, ...}: {
  imports = [
    ./dank.nix
    ./niri.nix
  ];

  config = {
    environment.systemPackages = with pkgs; [
      # Manage monitor layout
      wdisplays
    ];

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
  };
}
