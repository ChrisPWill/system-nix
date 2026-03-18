{
  inputs,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    # Include the graphical installer modules from nixpkgs
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares.nix"
    "${modulesPath}/installer/cd-dvd/channel.nix"

    # Include your shared system configuration
    inputs.self.nixosModules.host-shared
    inputs.self.nixosModules.nixos-shared
    inputs.self.nixosModules.graphical-environment
    inputs.self.nixosModules.personal-machine
  ];

  # Use the same host platform as your main laptop
  nixpkgs.hostPlatform = "x86_64-linux";
  nixpkgs.config.allowUnfree = true;

  # Customise the ISO image
  # isoImage.isoName is renamed to image.fileName in newer NixOS versions
  image.fileName = "nixos-installer-cwilliams-${pkgs.stdenv.hostPlatform.system}.iso";
  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;

  # Since we're in a live environment, we want to allow sudo without a password
  security.sudo.wheelNeedsPassword = false;

  # Set a password for the live user (cwilliams) in case it's needed
  users.users.cwilliams.initialPassword = "nixos";

  # Ensure the installer has access to your configuration
  # This makes it easier to install onto a new machine from the live environment
  environment.systemPackages = with pkgs; [
    git
    vim
  ];

  # QEMU guest additions for better VM testing
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  # Include the current flake in the ISO for easy installation
  # Once booted, you can install your config using:
  # sudo nixos-install --flake /etc/nix-config#cwilliams-laptop
  environment.etc."nix-config".source = inputs.self.outPath;

  # Optional: automatically log into the live session as 'cwilliams'
  # services.displayManager.autoLogin.enable = true;
  # services.displayManager.autoLogin.user = "cwilliams";
}
