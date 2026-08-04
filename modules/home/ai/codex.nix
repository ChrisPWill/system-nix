{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.home.ai;
  sharedRuleFiles = [
    ./shared-rules/code-style.md
    ./shared-rules/source-control.md
  ];
  sharedContext = builtins.toFile "shared-ai-rules.md" (
    lib.concatMapStringsSep "\n\n" builtins.readFile sharedRuleFiles
  );
in {
  config = lib.mkMerge [
    (lib.mkIf (cfg.agentProvider == "codex") {
      programs.codex = {
        enable = true;
        package = pkgs.codex;
        context = sharedContext;
      };
    })
    (lib.mkIf (cfg.neovimProvider == "codex") {
      home.packages = [pkgs.codex-acp];
    })
  ];
}
