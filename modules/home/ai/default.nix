{
  config,
  lib,
  ...
}: let
  scriptDir = "${config.homeModuleDir}/ai/scripts";
in {
  options.home.ai = {
    agentProvider = lib.mkOption {
      type = lib.types.enum ["codex" "gemini" "antigravity" "none"];
      default = "codex";
      description = "Primary command-line coding agent to configure.";
    };

    neovimProvider = lib.mkOption {
      type = lib.types.enum ["ollama" "gemini" "antigravity" "none"];
      default = "none";
      description = "Provider used by Neovim AI chat/completion plugins.";
    };
  };

  imports = [
    ./claude
    ./ollama.nix
    ./opencode.nix
    ./codex.nix
    ./gemini.nix
    ./antigravity.nix
  ];

  config = {
    home.sessionPath = [scriptDir];
    programs.nushell.extraEnv = ''
      $env.PATH = ($env.PATH | split row (char esep) | append "${scriptDir}")
    '';
  };
}
