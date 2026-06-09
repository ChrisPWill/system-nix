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
          rm -f ''${ZDOTDIR:-$HOME}/.zcompdump.zwc
          zcompile ''${ZDOTDIR:-$HOME}/.zcompdump
        fi
      '';

      initContent = ''
        typeset -ga zvm_after_init_commands

        function zvm_after_init() {
          local zvm_command
          for zvm_command in "''${zvm_after_init_commands[@]}"; do
            eval "$zvm_command"
          done
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
      };
    };
  };
}
