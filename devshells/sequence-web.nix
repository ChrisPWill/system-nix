{pkgs, ...}:
pkgs.mkShell {
  packages = with pkgs; [
    mkcert
  ];
}
