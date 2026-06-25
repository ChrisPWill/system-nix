{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: let
  scriptDir = "${config.homeModuleDir}/knowledge/scripts";
in {
  imports = [
    ./logseq-capture.nix
    inputs.knowledge-base.homeManagerModules.knowledge-base
  ];

  programs.knowledge-base.logseqShellSummary = {
    enable = true;
    package = inputs.knowledge-base.packages.${pkgs.stdenv.hostPlatform.system}.knowledge-base-summary;
    personalPath = "${config.home.homeDirectory}/knowledge-base/personal";
    workPath = "${config.home.homeDirectory}/knowledge-base/work";
    countOnlyTags = ["inbox"];
    digestTags = ["reminder"];
    intervalSeconds = 3600;
  };

  home.packages = with pkgs;
    [
      # Note taking
      gum
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

  home.sessionPath = [scriptDir];
  home.sessionVariables.LOGSEQ_QUICK_CAPTURE_JOURNALS_DIR = "${config.home.homeDirectory}/knowledge-base/${
    if config.isPersonalMachine
    then "personal"
    else "work"
  }/journals";

  programs.nushell.extraEnv = ''
    $env.PATH = ($env.PATH | split row (char esep) | append "${scriptDir}")
  '';
}
