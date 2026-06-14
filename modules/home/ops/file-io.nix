{pkgs, ...}: {
  home.packages = with pkgs; [
    # Easy zipper/unzipper
    ouch

    # Command line archiver with high compression ratio
    p7zip
  ];

  programs.yazi = {
    enable = true;
    shellWrapperName = "y";
    extraPackages = with pkgs; [
      ouch
      glow
    ];
    plugins = let
      yz = pkgs.yaziPlugins;
    in {
      inherit (yz) git; # Git status
      inherit (yz) sudo; # Call sudo
      inherit (yz) ouch; # Preview archives
      inherit (yz) glow; # Preview markdown files
      inherit (yz) mount; # Mount manager
      inherit (yz) starship; # Starship prompt integration
      relative-motions = yz."relative-motions"; # Vim-like motions
    };
  };
}
