{pkgs, ...}: {
  home.packages = with pkgs; [
    # A good font
    nerd-fonts.fantasque-sans-mono

    noto-fonts-cjk-sans

    dejavu_fonts
  ];

  fonts.fontconfig.enable = true;

  fonts.fontconfig.defaultFonts = {
    sansSerif = [
      "DejaVu Sans"
      "Noto Sans"
      "Noto Sans CJK KR"
    ];
    serif = ["DejaVu Serif" "Noto Serif" "Noto Serif CJK KR"];
    monospace = ["FantasqueSansM Nerd Font Mono"];
  };
}
