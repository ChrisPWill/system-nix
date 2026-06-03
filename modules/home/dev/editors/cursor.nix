{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./lsps.nix
  ];

  config = lib.mkIf pkgs.stdenv.isLinux {
    home.packages = with pkgs; [
      code-cursor-fhs
    ];
  };
}
