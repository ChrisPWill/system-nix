{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = lib.optionals config.isAtlassianMachine (with pkgs; [
    awscli2
  ]);
}
