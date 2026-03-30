{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.stylix.homeModules.stylix
    inputs.self.modules.theming.theme
  ];

  config = {
  };
}
