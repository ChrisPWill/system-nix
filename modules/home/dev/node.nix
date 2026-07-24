{
  config,
  pkgs,
  ...
}: let
  npmGlobalPrefix = "${config.xdg.dataHome}/npm";
in {
  home = {
    packages = [pkgs.nodejs_latest];

    # Keep globally installed npm packages outside the immutable Nix store.
    sessionVariables.NPM_CONFIG_PREFIX = npmGlobalPrefix;
    sessionPath = ["${npmGlobalPrefix}/bin"];
  };
}
