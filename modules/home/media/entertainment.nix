{
  pkgs,
  config,
  lib,
  ...
}: {
  home.packages = lib.optionals config.isPersonalMachine (with pkgs; [
    # steam extras
    steamcmd
    steam-tui

    spotify
  ]);
}
