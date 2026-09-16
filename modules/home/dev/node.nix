{
  config,
  lib,
  pkgs,
  ...
}: let
  npmGlobalPrefix = "${config.xdg.dataHome}/npm";
  # pnpm links global binaries into $PNPM_HOME/bin, and refuses to install
  # globally unless that directory is on PATH.
  pnpmHome = "${config.xdg.dataHome}/pnpm";
in {
  home = {
    # Work repositories declare their runtime versions through Mise metadata.
    packages = lib.optionals (!config.isWorkMachine) [pkgs.nodejs_latest];

    # Keep globally installed npm/pnpm packages outside the immutable Nix store.
    sessionVariables = {
      NPM_CONFIG_PREFIX = npmGlobalPrefix;
      PNPM_HOME = pnpmHome;
    };
    sessionPath = ["${npmGlobalPrefix}/bin" "${pnpmHome}/bin"];
  };
}
