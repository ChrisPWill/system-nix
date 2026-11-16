{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: {
  home.packages = with pkgs;
    lib.optionals config.appApproved.element [
      # Matrix chat
      element-desktop
    ]
    # Launcher, clipboard history and notes. Not in nixpkgs, so packaged in
    # packages/asyar.nix.
    ++ lib.optionals (stdenv.hostPlatform.isDarwin && config.appApproved.asyar) [
      inputs.self.packages.${stdenv.hostPlatform.system}.asyar
    ]
    # Local meeting notes. Not in nixpkgs or Homebrew, so packaged in
    # packages/yogurt.nix. Apple Silicon only.
    ++ lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64 && config.appApproved.yogurt) [
      inputs.self.packages.${stdenv.hostPlatform.system}.yogurt
    ]
    ++ lib.optionals config.isPersonalMachine [
      discord
      signal-desktop
    ];
}
