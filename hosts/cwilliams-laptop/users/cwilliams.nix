{
  inputs,
  config,
  ...
}: let
  hostHomeDir = "${config.nixConfigDir}/hosts/cwilliams-laptop/users";
in {
  imports = [
    inputs.self.homeModules.home-shared
    inputs.self.homeModules.graphical-nixos
    inputs.self.homeModules.personal-machine
  ];

  xdg.configFile."niri/niri-host.kdl".source = config.lib.file.mkOutOfStoreSymlink "${hostHomeDir}/graphical-nixos/niri-host.kdl";
}
