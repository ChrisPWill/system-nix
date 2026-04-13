{pkgs, ...}: {
  imports = [
    ./lsps.nix
  ];

  config = {
    home.packages = with pkgs; [
      code-cursor-fhs
    ];
  };
}
