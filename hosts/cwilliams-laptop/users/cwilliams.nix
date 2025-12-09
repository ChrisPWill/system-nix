{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.self.homeModules.home-shared
    inputs.self.homeModules.graphical-nixos
  ];

  home.packages = with pkgs; [
    discord
  ];
}
