{config, ...}: let
  scriptDir = "${config.homeModuleDir}/ops/scripts";
in {
  imports = [
    ./search.nix
    ./monitor.nix
    ./file-io.nix
    ./security.nix
    ./sops.nix
    ./syncthing.nix
  ];

  config = {
    home.sessionPath = [scriptDir];
  };
}
