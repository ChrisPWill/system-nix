{
  inputs,
  config,
  lib,
  perSystem,
  pkgs,
  ...
}: let
  neovimPackage = import ./nixcats-package.nix {
    inherit inputs lib pkgs;
    luaPath = config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/dev/editors/neovim/config";
    docsPath = "${config.homeModuleDir}/dev/editors/neovim/docs";
    kotlinLsp = perSystem.self.kotlin-lsp;
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
    programs = {
      zsh.shellAliases."nvimconfig" = "(cd ${config.homeModuleDir}/dev/editors/neovim; ${mainNixCatsPackageName} ./config/init.lua)";
      zsh.initContent = ''
        tv-nvim-widget() {
          zle -I
          tv-nvim < /dev/tty
          zle reset-prompt
        }

        zle -N tv-nvim-widget

        typeset -ga zvm_after_init_commands
        zvm_after_init_commands+=("zvm_bindkey viins '^[o' tv-nvim-widget")
      '';

      fish.interactiveShellInit = lib.mkAfter ''
        for mode in default insert
            bind --mode $mode \eo 'tv-nvim; commandline -f repaint'
        end
      '';

      nushell = {
        extraConfig = ''
          $env.config = (
            $env.config
            | upsert keybindings (
                $env.config.keybindings
                | append [
                    {
                        name: tv_nvim,
                        modifier: Alt,
                        keycode: char_o,
                        mode: [vi_normal, vi_insert, emacs],
                        event: {
                            send: executehostcommand,
                            cmd: "tv-nvim"
                        }
                    }
                ]
            )
          )
        '';
        extraEnv = ''
          $env.PATH = ($env.PATH | split row (char esep) | append "${scriptDir}")
        '';
      };
    };

    home = {
      sessionPath = [scriptDir];

      sessionVariables = {
        EDITOR = "meow";
        SUDO_EDITOR = "meow";
      };

      file."${config.xdg.configHome}/nvim/docs".source = config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/dev/editors/neovim/docs";
    };

    nixCats = {
      enable = true;

      addOverlays = neovimPackage.dependencyOverlays;
      packageNames = [mainNixCatsPackageName] ++ pkgs.lib.optionals config.isPersonalMachine ["leet" "nvim-llm"];
      luaPath = config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/dev/editors/neovim/config";

      categoryDefinitions.replace = neovimPackage.categoryDefinitions;
      packageDefinitions.replace = neovimPackage.packageDefinitions;
    };
  };
}
