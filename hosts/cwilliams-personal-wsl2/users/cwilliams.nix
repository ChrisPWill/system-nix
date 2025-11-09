{inputs, ...}: {
  imports = [inputs.self.homeModules.home-shared];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  programs.home-manager.enable = true;
}
