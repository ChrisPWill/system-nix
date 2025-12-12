{
  inputs,
  config,
  ...
}: let
  hostHomeDir = "${config.nixConfigDir}/hosts/cwilliams-laptop/users";
in {
  imports = [
    inputs.self.homeModules.graphical-nixos
  ];

  xdg.configFile."niri/niri-host.kdl".source = config.lib.file.mkOutOfStoreSymlink "${hostHomeDir}/graphical-nixos/niri-host.kdl";
}
