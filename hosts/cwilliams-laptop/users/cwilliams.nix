{
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.self.homeModules.home-shared];
}
