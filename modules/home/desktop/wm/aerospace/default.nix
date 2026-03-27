{
  config,
  pkgs,
  lib,
  ...
}: {
  # Aerospace window manager config
  xdg.configFile."aerospace/aerospace.toml" = lib.mkIf pkgs.stdenv.isDarwin {
    source = config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/desktop/wm/aerospace/aerospace.toml";
  };
}
