{
  config,
  lib,
  pkgs,
  ...
}: let
  pipxPackage = pkgs.pipx.overridePythonAttrs (_: {
    doCheck = false;
  });
in {
  home.packages = lib.optionals config.isAtlassianMachine [
    pipxPackage
  ];
}
