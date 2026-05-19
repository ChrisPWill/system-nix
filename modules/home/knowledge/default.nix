{
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    ./telegram-capture.nix
  ];

  services.telegram-capture.enable = false; # Enable this once I get the token set

  home.packages = with pkgs;
    [
      # Note taking
      logseq
    ]
    ++ lib.optionals config.isPersonalMachine [
      anki-bin
      mplayer # needed by anki
      mpv # needed by anki

      # Note taking/docs
      obsidian

      # Time tracking app for personal projects
      hours
    ];

  # PDF viewer
  programs.zathura.enable = true;
}
