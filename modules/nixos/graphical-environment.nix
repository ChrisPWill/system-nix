{inputs, ...}: {pkgs, ...}: {
  imports = [
    inputs.dankMaterialShell.nixosModules.greeter
    inputs.niri.nixosModules.niri
  ];

  config = {
    # Niri default polkit agent conflicts with dankMaterialShell
    # See https://danklinux.com/docs/dankmaterialshell/nixos#polkit-agent
    systemd.user.services.niri-flake-polkit.enable = false;
    programs.dankMaterialShell.greeter = {
      enable = true;
      compositor.name = "niri";
    };
    programs.niri.enable = true;
    programs.niri.package = pkgs.niri;

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
