{
  config,
  pkgs,
  lib,
  ...
}: let
  approved = config.appApproved;
in {
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
    bat.enable = approved.bat;

    # Auto use flakes when in directory (and allowed)
    # Remember to `direnv allow` in a project to get it going
    direnv.enable = approved.direnv;

    # ls alternative
    # https://github.com/eza-community/eza
    eza = {
      enable = approved.eza;
      git = true;
      icons = "auto";
    };

    # Nice fast autojump command
    # https://github.com/ajeetdsouza/zoxide
    zoxide.enable = approved.zoxide;

    # Command history
    atuin.enable = approved.atuin;

    # Autocompletion in shell
    carapace.enable = approved.carapace;
  };

  home.packages = config.filterApproved ({
      inherit
        (pkgs)
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
        # Retrieve files from the web
        wget
        # Terminal-based websocket client
        websocat
        ;
    }
    // lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
      # Display Gtk+ dialog boxes from shell scripts
      inherit (pkgs) zenity;
    });
}
