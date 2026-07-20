{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.dankGreeter.nixosModules.default
  ];

  config = {
    environment.systemPackages = with pkgs; [
      accountsservice # profile pics, etc.
      power-profiles-daemon # performance mode, etc.
    ];

    services.displayManager.dms-greeter = {
      enable = true;
      compositor.name = "niri";
    };

    # Niri default polkit agent conflicts with dankMaterialShell
    # See https://danklinux.com/docs/dankmaterialshell/nixos#polkit-agent
    systemd.user.services.niri-flake-polkit.enable = false;
  };
}
