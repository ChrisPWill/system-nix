{
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.self.homeModules.home-shared];

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.package = pkgs.nix;

  programs.home-manager.enable = true;
}
