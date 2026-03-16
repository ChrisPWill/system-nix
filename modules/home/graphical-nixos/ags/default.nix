{
  inputs,
  config,
  ...
}: let
  agsDir = "${config.homeModuleDir}/graphical-nixos/ags";
in {
  imports = [inputs.ags.homeManagerModules.default];

  programs.ags = {
    enable = true;

    configDir = config.lib.file.mkOutOfStoreSymlink "${agsDir}/config";

    # Add extra packages
    # extraPackages = with pkgs; [
    #   inputs.astal.packages.${pkgs.system}.battery
    # ];
  };
}
