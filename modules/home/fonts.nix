{pkgs, ...}: {
  home.packages = with pkgs; [
    # A good font
    nerd-fonts.fantasque-sans-mono

    noto-fonts-cjk-sans

    roboto

    roboto-serif
  ];

  fonts.fontconfig.enable = true;

  fonts.fontconfig.defaultFonts = {
    sansSerif = [
      "Roboto"
      "Noto Sans"
      "Noto Sans CJK KR"
    ];
    serif = ["Roboto Serif" "Noto Serif" "Noto Serif CJK KR"];
    monospace = ["FantasqueSansM Nerd Font Mono"];
  };
}
