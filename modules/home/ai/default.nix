{
  config,
  lib,
  ...
}: let
  scriptDir = "${config.homeModuleDir}/ai/scripts";
  # ai-ask and ai-commit shell out to an agent CLI, so without one the
  # scripts and their keybindings only produce errors.
  cfg = config.home.ai;
  # Named after their approved-apps entries so approval can be looked up
  # directly.
  harnessNames = ["claude-code" "codex" "gemini-cli"];
  hasAgentCli = lib.any lib.id (lib.attrValues cfg.harnessEnabled);
in {
  options.home.ai = {
    harnesses = lib.mkOption {
      type = lib.types.listOf (lib.types.enum harnessNames);
      default = ["claude-code" "codex"];
      description = ''
        Command-line coding agents to install side by side. Each is still
        installed only if approved on this machine.
      '';
    };

    harnessEnabled = lib.mkOption {
      type = lib.types.attrsOf lib.types.bool;
      readOnly = true;
      # Modules read `harnessEnabled.<name>` rather than checking the list and
      # approval separately, so the two can't drift apart.
      default = lib.genAttrs harnessNames (name: lib.elem name cfg.harnesses && config.appApproved.${name});
      description = "Whether each harness is both chosen and approved. Derived from harnesses.";
    };

    neovimProvider = lib.mkOption {
      type = lib.types.enum ["codex" "ollama" "gemini" "none"];
      default = "codex";
      description = "Provider used by Neovim AI chat/completion plugins.";
    };
  };

  imports = [
    ./shared-skills.nix
    ./claude
    ./ollama.nix
    ./memory
    ./opencode.nix
    ./codex.nix
    ./gemini.nix
  ];

  config = lib.mkIf hasAgentCli {
    home.sessionPath = [scriptDir];
    programs = {
      nushell = {
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
