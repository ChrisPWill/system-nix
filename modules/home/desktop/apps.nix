{
  pkgs,
  config,
  lib,
  ...
}: {
  home.packages = with pkgs;
    [
      # Matrix chat
      element-desktop
    ]
    ++ lib.optionals config.isPersonalMachine [
      discord
      signal-desktop
    ];
}
