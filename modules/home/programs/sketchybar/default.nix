{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf pkgs.stdenv.isDarwin {
    programs.sketchybar.enable = true;

    xdg.configFile."sketchybar/sketchybarrc" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/programs/sketchybar/sketchybar.sh";
    };
    xdg.configFile."sketchybar/plugins" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/programs/sketchybar/plugins";
    };
  };
}
