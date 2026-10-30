{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.self.homeModules.home-shared
    inputs.self.homeModules.standalone
  ];

  nix.package = pkgs.nix;

  programs.home-manager.enable = true;
}
