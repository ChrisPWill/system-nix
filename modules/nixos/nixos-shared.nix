{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.stylix.nixosModules.stylix
  ];

  config = {
    stylix.enable = true;
    stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";

    users.defaultUserShell = pkgs.zsh;

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.cwilliams = {
      isNormalUser = true;
      description = "Chris Williams";
      extraGroups = ["networkmanager" "wheel"];
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
  };
}
