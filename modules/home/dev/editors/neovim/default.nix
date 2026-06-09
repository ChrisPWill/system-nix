{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: let
  neovimPackage = import ./nixcats-package.nix {
    inherit inputs lib pkgs;
    luaPath = config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/dev/editors/neovim/config";
    docsPath = "${config.homeModuleDir}/dev/editors/neovim/docs";
    enableCopilot = config.nixCats.custom.enableCopilot;
    enableLocalOllama = config.services.local-ollama.enable;
    neovimProvider = config.home.ai.neovimProvider;
    geminiApiKeyPath = config.sops.secrets.gemini_api_key.path;
  };

  inherit (neovimPackage) mainNixCatsPackageName;
  scriptDir = "${config.homeModuleDir}/dev/editors/neovim/scripts";
in {
  imports = [
    inputs.nixCats.homeModule
  ];

  options = {
    nixCats.custom = {
      enableCopilot = lib.mkEnableOption "Enable Copilot in Neovim (nixCats)";
    };
  };

  config = {
    programs.zsh.shellAliases."nvimconfig" = "(cd ${config.homeModuleDir}/dev/editors/neovim; ${mainNixCatsPackageName} ./config/init.lua)";

    home.sessionPath = [scriptDir];
    programs.nushell.extraEnv = ''
      $env.PATH = ($env.PATH | split row (char esep) | append "${scriptDir}")
    '';

    home.sessionVariables = {
      EDITOR = "meow";
      SUDO_EDITOR = "meow";
    };

    home.file."${config.xdg.configHome}/nvim/docs".source = config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/dev/editors/neovim/docs";

    nixCats = {
      enable = true;

      addOverlays = neovimPackage.dependencyOverlays;
      packageNames = [mainNixCatsPackageName] ++ pkgs.lib.optionals config.isPersonalMachine ["leet" "nvim-ai" "nvim-llm"];
      luaPath = config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/dev/editors/neovim/config";

      categoryDefinitions.replace = neovimPackage.categoryDefinitions;
      packageDefinitions.replace = neovimPackage.packageDefinitions;
    };
  };
}
