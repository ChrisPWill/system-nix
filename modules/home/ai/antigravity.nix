{
  config,
  lib,
  ...
}: let
  cfg = config.home.ai;
in {
  config = lib.mkIf (cfg.agentProvider == "antigravity" || cfg.neovimProvider == "antigravity") {
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
  };
}
