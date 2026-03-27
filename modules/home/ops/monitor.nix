{pkgs, ...}: {
  home.packages = with pkgs; [
    # TUI to browse quite a few journals/logs.
    # Great for docker, journald, systemd logs etc.
    # https://github.com/Lifailon/lazyjournal
    lazyjournal
  ];
}
