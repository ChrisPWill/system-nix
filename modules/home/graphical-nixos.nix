{inputs, ...}: {...}: {
  imports = [
    inputs.dankMaterialShell.homeModules.dankMaterialShell.default
    inputs.dankMaterialShell.homeModules.dankMaterialShell.niri
  ];

  config = {
    # Complete desktop shell for Wayland compositors e.g. niri/hyprland
    programs.dankMaterialShell = {
      enable = true;
    };
    # Niri https://yalter.github.io/niri/
    programs.dankMaterialShell.niri = {
      enableKeybinds = true;
      enableSpawn = true;
    };
  };
}
