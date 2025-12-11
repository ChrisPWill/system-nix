{inputs, ...}: {
  imports = [
    inputs.dankMaterialShell.nixosModules.greeter
  ];

  config = {
    programs.dankMaterialShell.greeter = {
      enable = true;
      compositor.name = "niri";
    };

    # Niri default polkit agent conflicts with dankMaterialShell
    # See https://danklinux.com/docs/dankmaterialshell/nixos#polkit-agent
    systemd.user.services.niri-flake-polkit.enable = false;
  };
}
