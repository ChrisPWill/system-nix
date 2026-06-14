{
  pkgs,
  lib,
  ...
}: {
  programs = {
    zsh.initContent = ''
      viddy-widget() {
        local cmd=$BUFFER
        if [[ -n $cmd ]]; then
          BUFFER="viddy -n 1 -- $cmd"
          zle accept-line
        fi
      }

      zle -N viddy-widget

      typeset -ga zvm_after_init_commands
      zvm_after_init_commands+=("zvm_bindkey viins '^[w' viddy-widget")
      zvm_after_init_commands+=("zvm_bindkey viins '^R' atuin-search-viins")
    '';

    fish.interactiveShellInit = lib.mkAfter ''
      for mode in default insert
          bind --mode $mode \ew 'set -l cmd (commandline); if test -n "$cmd"; commandline -r "viddy -n 1 -- $cmd"; commandline -f execute; end'
      end
    '';

    nushell.extraConfig = ''
      $env.config = (
        $env.config
        | upsert keybindings (
            $env.config.keybindings
            | append [
                {
                    name: viddy_command,
                    modifier: Alt,
                    keycode: char_w,
                    mode: [vi_normal, vi_insert, emacs],
                    event: {
                        send: executehostcommand,
                        cmd: "let cmd = (commandline); if ($cmd | str length) > 0 { viddy -n 1 -- $cmd }"
                    }
                }
            ]
        )
      )
    '';

    # Nice colourful cat alternative
    # https://github.com/sharkdp/bat
    bat.enable = true;

    # Auto use flakes when in directory (and allowed)
    # Remember to `direnv allow` in a project to get it going
    direnv.enable = true;

    # ls alternative
    # https://github.com/eza-community/eza
    eza = {
      enable = true;
      git = true;
      icons = "auto";
    };

    # Nice fast autojump command
    # https://github.com/ajeetdsouza/zoxide
    zoxide.enable = true;

    # Command history
    atuin.enable = true;

    # Autocompletion in shell
    carapace.enable = true;
  };

  home.packages = with pkgs;
    [
      # Fast alternative to find
      # https://github.com/sharkdp/fd
      fd

      # Fast grep
      ripgrep

      # Rust-based ps replacement
      procs

      # Watch progress of cp/mv/dd/tar/etc. `tldr progress` for info
      progress

      # Modern watch replacement
      viddy

      # Glamorous shell scripts
      gum

      # Terminal-based websocket client
      websocat

      # Retrieve files from the web
      wget
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      # Display Gtk+ dialog boxes from shell scripts
      zenity
    ];
}
