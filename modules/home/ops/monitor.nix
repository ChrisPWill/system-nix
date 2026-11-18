{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs;
    lib.optionals config.appApproved.btop [
      # Preferred task manager on macOS: Activity Monitor polling sysmond can
      # drive PerfPowerServices to 100%+ CPU, which btop avoids.
      btop
    ]
    ++ lib.optionals config.appApproved.lazyjournal [
      # TUI to browse quite a few journals/logs.
      # Great for docker, journald, systemd logs etc.
      # https://github.com/Lifailon/lazyjournal
      lazyjournal
    ];
}
