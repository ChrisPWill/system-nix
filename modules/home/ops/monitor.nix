{pkgs, ...}: {
  home.packages = with pkgs; [
    # Rust-based ps replacement
    procs

    # Watch progress of cp/mv/dd/tar/etc. `tldr progress` for info
    progress

    # TUI to browse quite a few journals/logs.
    # Great for docker, journald, systemd logs etc.
    # https://github.com/Lifailon/lazyjournal
    lazyjournal
  ];
}
