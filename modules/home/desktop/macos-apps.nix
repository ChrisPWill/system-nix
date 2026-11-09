{
  lib,
  pkgs,
  ...
}: {
  # Spotlight doesn't index Home Manager's default links into the Nix store,
  # so copy app bundles instead to make them findable with Command-Space.
  targets.darwin = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    linkApps.enable = false;
    copyApps.enable = true;
  };
}
