{pkgs, ...}: {
  home.packages = with pkgs; [
    discord

    # steam extras
    steamcmd
    steam-tui

    anki-bin
  ];
}
