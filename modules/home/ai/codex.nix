{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.home.ai;
in {
  config = lib.mkMerge [
    (lib.mkIf (cfg.agentProvider == "codex") {
      home.packages = [pkgs.codex];
    })
    (lib.mkIf (cfg.neovimProvider == "codex") {
      home.packages = [pkgs.codex-acp];
    })
  ];
}
