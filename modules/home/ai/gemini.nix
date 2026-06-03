{config, ...}: {
  # Backup configuration - migrating to antigravity
  programs = {
    gemini-cli = {
      enable = true;
      settings = {
        general = {
          vimMode = true;
          preferredEditor = "neovim";
        };

        security.auth.selectedType = "oauth-personal";

        privacy.usageStatisticsEnabled = false;
      };

      # Example context for later if I choose to add it
      # context = {
      #   GEMINI = ''
      #     # Global Context

      #     You are a helpful AI assistant for software development.

      #     ## Coding Standards

      #     - Follow consistent code style
      #     - Write clear comments
      #     - Test your changes
      #   '';

      #   AGENTS = ./path/to/agents.md;

      #   CONTEXT = ''
      #     Additional context instructions here.
      #   '';
      # };
    };
  };

  home.file.".gemini/gemini-cli/mcp_config.json".source = config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/ai/mcp_config.json";
}
