{pkgs, ...}: {
  programs.foot = {
    enable = pkgs.stdenv.isLinux;
    settings = {
      mouse = {
        hide-when-typing = "yes";
      };
    };
  };
}
