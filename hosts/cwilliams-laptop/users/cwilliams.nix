{inputs, ...}: {
  imports = [
    inputs.self.homeModules.home-shared
    inputs.self.homeModules.personal-machine

    ./graphical-nixos
  ];
}
