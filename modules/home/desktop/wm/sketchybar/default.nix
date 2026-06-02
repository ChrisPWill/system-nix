{
  config,
  lib,
  pkgs,
  ...
}: let
  enableSketchybarForDarwin = false;
in {
  # Disabled during the OmniWM migration; this config currently depends on Aerospace.
  config = lib.mkIf (pkgs.stdenv.isDarwin && enableSketchybarForDarwin) {
    programs.sketchybar.enable = true;

    xdg.configFile."sketchybar/sketchybarrc" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/desktop/wm/sketchybar/sketchybar.sh";
    };
    xdg.configFile."sketchybar/plugins" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/desktop/wm/sketchybar/plugins";
    };
  };
}
