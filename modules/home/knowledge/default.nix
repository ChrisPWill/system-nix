{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: {
  imports = [
    ./logseq-capture.nix
    inputs.knowledge-base.homeManagerModules.knowledge-base
  ];

  programs.knowledge-base.logseqShellSummary = {
    enable = true;
    personalPath = "${config.home.homeDirectory}/knowledge-base/personal";
    workPath = "${config.home.homeDirectory}/knowledge-base/work";
    countOnlyTags = ["inbox"];
    digestTags = ["reminder"];
    intervalSeconds = 3600;
  };

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
  programs.zathura.enable = !pkgs.stdenv.isDarwin; # Disabled on MacOS due to https://github.com/NixOS/nixpkgs/issues/514566
}
