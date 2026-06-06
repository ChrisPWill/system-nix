{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.home.ai;
in {
  config = lib.mkIf (cfg.agentProvider == "codex") {
    home.packages = [
      pkgs.codex
    ];
  };
}
