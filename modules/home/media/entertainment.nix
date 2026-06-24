{
  pkgs,
  config,
  lib,
  ...
}: {
  home.packages = with pkgs;
    lib.optionals config.isPersonalMachine [
      # steam extras
      steamcmd
      steam-tui
    ]
    ++ [
      spotify
    ];
}
