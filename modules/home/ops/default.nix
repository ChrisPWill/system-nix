{config, ...}: let
  scriptDir = "${config.homeModuleDir}/ops/scripts";
in {
  imports = [
    ./cloud.nix
    ./search.nix
    ./monitor.nix
    ./file-io.nix
    ./security.nix
    ./sops.nix
    ./syncthing.nix
  ];

  config = {
    home.sessionPath = [scriptDir];
    programs.nushell.extraEnv = ''
      $env.PATH = ($env.PATH | split row (char esep) | append "${scriptDir}")
    '';
  };
}
