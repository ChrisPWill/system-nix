{pkgs, ...}: {
  home.packages = with pkgs; [
    # A good font
    nerd-fonts.fantasque-sans-mono

    noto-fonts-cjk-sans
  ];

  fonts.fontconfig.enable = true;

  fonts.fontconfig.defaultFonts = {
    sansSerif = [
      "Noto Sans"
      "Noto Sans CJK KR"
    ];
    serif = ["Noto Serif" "Noto Serif CJK KR"];
    monospace = ["FantasqueSansM Nerd Font Mono"];
  };
}
