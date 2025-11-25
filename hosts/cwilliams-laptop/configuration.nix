{inputs, ...}: {
  imports = [
    ./hardware-configuration.nix
    inputs.self.nixosModules.host-shared
    inputs.self.nixosModules.nixos-shared
    inputs.self.nixosModules.graphical-environment
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  nixpkgs.config.allowUnfree = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-3d722d8b-ae18-4ff6-ba21-e4743d9f9250".device = "/dev/disk/by-uuid/3d722d8b-ae18-4ff6-ba21-e4743d9f9250";
  networking.hostName = "cwilliams-laptop"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.cwilliams = {
    isNormalUser = true;
    description = "Chris Williams";
    extraGroups = ["networkmanager" "wheel"];
  };

  environment.systemPackages = [];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
