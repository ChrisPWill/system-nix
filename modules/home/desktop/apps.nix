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
    ++ lib.optionals config.isPersonalMachine [
      discord
      signal-desktop
    ];
}
