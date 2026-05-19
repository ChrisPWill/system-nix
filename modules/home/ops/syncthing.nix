{
  config,
  lib,
  pkgs,
  ...
}: {
  services.syncthing = {
    enable = true;
    # Web UI will be available at http://127.0.0.1:8384
  };
}
