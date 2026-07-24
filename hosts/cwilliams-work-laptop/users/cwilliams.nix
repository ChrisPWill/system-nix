{inputs, ...}: {
  imports = [
    inputs.self.homeModules.home-shared
    inputs.self.homeModules.sequence
  ];

  usesDeterminateNix = true;
}
