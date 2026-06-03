{config, ...}: {
  programs.antigravity = {
    enable = true;
    profiles.default = {
      userSettings = {
        "antigravity.general.vimMode" = true;
        "antigravity.general.preferredEditor" = "neovim";
        "antigravity.security.auth.selectedType" = "oauth-personal";
        "antigravity.privacy.usageStatisticsEnabled" = false;
      };
    };
  };

  home.file.".gemini/antigravity/mcp_config.json".source = config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/ai/mcp_config.json";
}
