{
  pkgs,
  config,
  lib,
  ...
}: {
  home.packages = with pkgs;
    lib.optionals config.appApproved.element [
      # Matrix chat
      element-desktop
    ]
    ++ lib.optionals config.isPersonalMachine [
      discord
      signal-desktop
    ];
}
