{
  pkgs,
  config,
  lib,
  ...
}: {
  home.packages = lib.optionals config.isPersonalMachine (with pkgs; [
    bitwarden-cli
  ]);
}
