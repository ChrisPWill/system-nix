{
  config,
  pkgs,
  ...
}: {
  programs.foot = {
    enable = pkgs.stdenv.hostPlatform.isLinux && config.appApproved.foot;
    settings = {
      mouse = {
        hide-when-typing = "yes";
      };
    };
  };
}
