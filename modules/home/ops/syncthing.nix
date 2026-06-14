{config, ...}: {
  services.syncthing = {
    enable = !config.isAtlassianMachine;
    # Web UI will be available at http://127.0.0.1:8384
  };
}
