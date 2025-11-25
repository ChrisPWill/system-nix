{inputs, pkgs, ...}: {
  imports = [inputs.self.homeModules.home-shared];

  home.packages = with pkgs; [
    discord
  ];
}
