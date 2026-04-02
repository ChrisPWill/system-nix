{inputs, ...}: {
  imports = [
    inputs.self.homeModules.home-shared
    inputs.self.homeModules.graphical-nixos
  ];

  # Simplified config for the installer/live environment
  # We don't use the host-specific overrides here to keep it portable
}
