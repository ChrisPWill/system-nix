{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: let
  scriptDir = "${config.homeModuleDir}/knowledge/scripts";
  approved = config.appApproved;
in {
  imports = [
    ./logseq-capture.nix
    inputs.knowledge-base.homeManagerModules.knowledge-base
  ];

  programs.knowledge-base.logseqShellSummary = {
    enable = approved.logseq;
    package = inputs.knowledge-base.packages.${pkgs.stdenv.hostPlatform.system}.knowledge-base-summary;
    personalPath = "${config.home.homeDirectory}/knowledge-base/personal";
    workPath = "${config.home.homeDirectory}/knowledge-base/work";
    countOnlyTags = ["inbox"];
    digestTags = ["reminder"];
    intervalSeconds = 3600;
  };

  home.packages = with pkgs;
    config.filterApproved {inherit gum;}
    ++ lib.optionals approved.logseq [
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
  programs.zathura.enable = approved.zathura;

  home.sessionPath = lib.optionals approved.logseq [scriptDir];
  home.sessionVariables.LOGSEQ_QUICK_CAPTURE_JOURNALS_DIR = lib.mkIf approved.logseq "${config.home.homeDirectory}/knowledge-base/${
    if config.isPersonalMachine
    then "personal"
    else "work"
  }/journals";
}
