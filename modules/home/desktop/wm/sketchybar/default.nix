{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf pkgs.stdenv.isDarwin {
    programs.sketchybar = {
      enable = true;
      extraPackages = [pkgs.jq];
      service.enable = false;
    };

    xdg.configFile."sketchybar/sketchybarrc" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/desktop/wm/sketchybar/sketchybar.sh";
    };
    xdg.configFile."sketchybar/plugins" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/desktop/wm/sketchybar/plugins";
    };
  };
}
