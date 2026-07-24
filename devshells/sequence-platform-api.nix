{pkgs, ...}:
pkgs.mkShell {
  packages = with pkgs; [
    cloudflared
    google-cloud-sdk
    libpq
    libyaml
  ];
}
