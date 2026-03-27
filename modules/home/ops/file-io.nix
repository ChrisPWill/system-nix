{pkgs, ...}: {
  home.packages = with pkgs; [
    # Easy zipper/unzipper
    ouch
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
      git = yz.git; # Git status
      sudo = yz.sudo; # Call sudo
      ouch = yz.ouch; # Preview archives
      glow = yz.glow; # Preview markdown files
      mount = yz.mount; # Mount manager
      starship = yz.starship; # Starship prompt integration
      relative-motions = yz."relative-motions"; # Vim-like motions
    };
  };
}
