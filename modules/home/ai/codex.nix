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
    ./shared-rules/graphiti-memory.md
  ];
  # Must stay a string of content: programs.codex.context only treats a Nix
  # path value as a file, so a store-path *string* would be written verbatim.
  sharedContext = lib.concatMapStringsSep "\n\n" builtins.readFile sharedRuleFiles;
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
