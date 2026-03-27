{
  config,
  pkgs,
  ...
}: {
  config = {
    programs.zsh = {
      enable = true;
      completionInit = ''
        autoload -Uz compinit
        if [[ -n ''${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
          compinit
        else
          compinit -C
        fi
        if [[ ! -f ''${ZDOTDIR:-$HOME}/.zcompdump.zwc ||
              ''${ZDOTDIR:-$HOME}/.zcompdump -nt ''${ZDOTDIR:-$HOME}/.zcompdump.zwc ]]; then
          zcompile ''${ZDOTDIR:-$HOME}/.zcompdump
        fi
      '';

      initContent = ''
        tv-nvim-widget() {
          # Notify ZLE that we are going to use the terminal
          zle -I

          # Run the command with stdin redirected to the terminal
          # Also, use 'command' if it's a binary, or ensure the function is defined
          tv-nvim < /dev/tty

          # Redraw the prompt so your line doesn't look broken
          zle reset-prompt
        }

        zle -N tv-nvim-widget

        # Define extra bindings for zsh-vi-mode
        function zvm_after_init() {
          zvm_bindkey viins '^[o' tv-nvim-widget
          # Re-bind Atuin and Television which are often clobbered by vi-mode
          zvm_bindkey viins '^R' atuin-search-viins
          zvm_bindkey viins '^T' tv-smart-autocomplete
        }
      '';

      plugins = [
        {
          name = "vi-mode";
          src = pkgs.zsh-vi-mode;
          file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
        }
      ];

      dotDir = "${config.home.homeDirectory}/.config/zsh";

      history = {
        size = 10000;
        save = 10000;
        path = "$HOME/.config/zsh/.zshinfo";
        share = true;

        ignoreSpace = true;
        ignoreDups = true;
        extended = true;
        expireDuplicatesFirst = true;
      };

      shellAliases = {
        # Quick alias to enable a devshell
        nd = "f() { nix develop ${config.nixConfigDir}/.#$1 --command zsh };f";
      };
    };
  };
}
