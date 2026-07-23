{
  config,
  lib,
  ...
}: let
  scriptDir = "${config.homeModuleDir}/ai/scripts";
in {
  options.home.ai = {
    agentProvider = lib.mkOption {
      type = lib.types.enum ["codex" "gemini" "none"];
      default = "codex";
      description = "Primary command-line coding agent to configure.";
    };

    neovimProvider = lib.mkOption {
      type = lib.types.enum ["codex" "ollama" "gemini" "none"];
      default = "codex";
      description = "Provider used by Neovim AI chat/completion plugins.";
    };
  };

  imports = [
    ./claude
    ./ollama.nix
    ./opencode.nix
    ./codex.nix
    ./gemini.nix
  ];

  config = {
    home.sessionPath = [scriptDir];
    programs = {
      nushell = {
        extraEnv = ''
          $env.PATH = ($env.PATH | split row (char esep) | append "${scriptDir}")
        '';
        extraConfig = ''
          $env.config = (
            $env.config
            | upsert keybindings (
                $env.config.keybindings
                | append [
                    {
                        name: ai_commit,
                        modifier: Control,
                        keycode: char_g,
                        mode: [vi_normal, vi_insert, emacs],
                        event: {
                            send: executehostcommand,
                            cmd: "ai-commit"
                        }
                    }
                ]
            )
          )
        '';
      };

      zsh.initContent = ''
        ai-commit-widget() {
          zle -I
          ai-commit < /dev/tty
          zle reset-prompt
        }

        zle -N ai-commit-widget

        typeset -ga zvm_after_init_commands
        zvm_after_init_commands+=("zvm_bindkey viins '^g' ai-commit-widget")
      '';

      fish.interactiveShellInit = lib.mkAfter ''
        for mode in default insert
            bind --mode $mode \cg 'ai-commit; commandline -f repaint'
        end
      '';
    };
  };
}
