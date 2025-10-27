{pkgs, ...}: {
  environment.systemPackages =
    [
      pkgs.btop
    ]
    # you can check if host is darwin by using pkgs.stdenv.isDarwin
    #++ (pkgs.lib.optionals pkgs.stdenv.isDarwin [pkgs.xbar])
    ;
}
