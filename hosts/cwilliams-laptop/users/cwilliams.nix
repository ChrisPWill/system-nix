{inputs, ...}: {
  imports = [
    inputs.self.homeModules.home-shared
    inputs.self.homeModules.graphical-nixos
    inputs.self.homeModules.personal-machine
  ];
}
