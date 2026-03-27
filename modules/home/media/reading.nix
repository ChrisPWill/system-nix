{pkgs, ...}: {
  home.packages = with pkgs; [
    # Note taking
    logseq
  ];

  # PDF viewer
  programs.zathura.enable = true;
}
