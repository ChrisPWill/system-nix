{inputs, ...}: {
  imports = [inputs.self.homeModules.home-shared];

  programs.home-manager.enable = true;
}
