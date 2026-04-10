{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.stylix.nixosModules.stylix
    inputs.self.modules.theming.theme
    ./ops
  ];

  config = {
    # Required for kanata to simulate keyboard input
    boot.kernelModules = ["uinput"];
    users.defaultUserShell = pkgs.zsh;

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.cwilliams = {
      isNormalUser = true;
      description = "Chris Williams";
      extraGroups = [
        "networkmanager"
        "wheel"
        "docker"
        "input" # Required for kanata to read keyboard events
        "uinput" # Required for kanata to emit keyboard events
      ];
    };

    # Set your time zone.
    time.timeZone = "Asia/Seoul";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_GB.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_AU.UTF-8";
      LC_IDENTIFICATION = "en_AU.UTF-8";
      LC_MEASUREMENT = "en_AU.UTF-8";
      LC_MONETARY = "en_AU.UTF-8";
      LC_NAME = "en_AU.UTF-8";
      LC_NUMERIC = "en_AU.UTF-8";
      LC_PAPER = "en_AU.UTF-8";
      LC_TELEPHONE = "en_AU.UTF-8";
      LC_TIME = "en_AU.UTF-8";
    };

    # Configure keymap in X11
    services.xserver.xkb = {
      layout = "au";
      variant = "";
    };

    virtualisation.docker.enable = true;

    services.flatpak.enable = true;

    services.openssh.enable = true;

    # Group for kanata to access /dev/uinput
    users.groups.uinput = {};
    # Udev rule to allow the uinput group to write to /dev/uinput
    services.udev.extraRules = ''
      KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
    '';
  };
}
