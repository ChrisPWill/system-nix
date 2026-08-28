{pkgs, ...}: {
  programs.foot = {
    enable = pkgs.stdenv.hostPlatform.isLinux;
    settings = {
      mouse = {
        hide-when-typing = "yes";
      };
    };
  };
}
