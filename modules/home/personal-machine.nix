{pkgs, ...}: {
  home.packages = with pkgs; [
    discord

    # steam extras
    steamcmd
    steam-tui

    anki-bin
    mplayer # needed by anki
    mpv # needed by anki

    # messaging app
    signal-desktop
  ];
}
