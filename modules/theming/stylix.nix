{pkgs, ...}: {
  stylix.enable = true;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/onedark.yaml";

  stylix.fonts = {
    monospace = {
      package = pkgs.nerd-fonts.fantasque-sans-mono;
      name = "FantasqueSansM Nerd Font Mono";
    };
    sizes.terminal = 12;
  };

  stylix.opacity.terminal = 0.9;
}
