{
  config,
  lib,
  pkgs,
  ...
}: let
  npmGlobalPrefix = "${config.xdg.dataHome}/npm";
in {
  home = {
    # Work repositories declare their runtime versions through Mise metadata.
    packages = lib.optionals (!config.isWorkMachine) [pkgs.nodejs_latest];

    # Keep globally installed npm packages outside the immutable Nix store.
    sessionVariables.NPM_CONFIG_PREFIX = npmGlobalPrefix;
    sessionPath = ["${npmGlobalPrefix}/bin"];
  };
}
