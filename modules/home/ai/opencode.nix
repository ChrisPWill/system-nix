{
  config,
  lib,
  ...
}: {
  programs.opencode = {
    enable = true;

    # Stylix still selects its theme through tui.json, which OpenCode 2 ignores
    # in favour of cli.json.
    tui = lib.mkForce {};
    cli.theme.name = "stylix";

    settings = {
      provider.ollama = {
        npm = "@ai-sdk/openai-compatible";
        name = "Ollama (local)";
        options = {
          baseURL = "http://localhost:11434/v1";
        };
        models = {
          "qwen2.5-coder:3b-base" = {
            name = "Qwen 2.5 Coder (3B)";
          };
        };
      };
    };
  };

  xdg.configFile."opencode/AGENTS.md".source = config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/ai/rules/AGENTS.md";
  xdg.configFile."opencode/general-guidelines.md".source = config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/ai/rules/general-guidelines.md";
}
