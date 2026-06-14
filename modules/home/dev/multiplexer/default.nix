# Terminal multiplexer
# https://zellij.dev
{config, ...}: {
  programs = {
    zellij = {
      enable = true;
      settings = {
        default_layout = "compact";
        scroll_buffer_size = 10000;
        copy_on_select = true;
        pane_frames = false;

        theme = "onedark";
      };
    };

    fish = {
      functions = {
        zz = ''
          if test -n "$argv[1]"
            zellij attach -c $argv[1]
          else
            zellij attach -c default
          end
        '';
        za = ''
          if test -n "$argv[1]"
            zellij attach $argv[1]
          else
            zellij attach default
          end
        '';
        edit = ''
          # Grab the first argument, if it exists
          set -l session_name "$argv[1]"

          # If no argument was provided, try to get the repo-name
          if test -z "$session_name"
            set session_name (repo-name 2>/dev/null)
          end

          # If we now have a valid session_name (either from arg or repo-name)
          if test -n "$session_name"
            zellij -l dev attach -c "$session_name"
          else
            zellij -l dev
          end
        '';
      };
      shellAliases = {
        zr = "zellij run --";
        zrf = "zellij run --floating --";
        zl = "zellij list-sessions";
        zk = "zellij kill-session";
        zka = "zellij kill-all-sessions";
        zd = "zellij delete-session";
        zda = "zellij delete-all-sessions";
      };
    };

    zsh = {
      shellAliases = {
        zz = "f() { zellij attach -c ''\${1:-default} };f";
        zr = "zellij run --";
        zrf = "zellij run --floating --";
        za = "f() { zellij attach ''\${1:-default} };f";
        zl = "zellij list-sessions";
        zk = "zellij kill-session";
        zka = "zellij kill-all-sessions";
        zd = "zellij delete-session";
        zda = "zellij delete-all-sessions";
      };
      initContent = ''
        edit() {
          local session_name="$1"

          # If no argument was provided, try to get the repo-name
          if [[ -z "$session_name" ]]; then
            session_name="$(repo-name 2>/dev/null)"
          fi

          # If we have a valid session_name
          if [[ -n "$session_name" ]]; then
            zellij -l dev attach -c "$session_name"
          else
            zellij -l dev
          fi
        }
      '';
    };

    nushell = {
      shellAliases = {
        zr = "zellij run --";
        zrf = "zellij run --floating --";
        zl = "zellij list-sessions";
        zk = "zellij kill-session";
        zka = "zellij kill-all-sessions";
        zd = "zellij delete-session";
        zda = "zellij delete-all-sessions";
      };
      extraConfig = ''
        def zz [name?: string] {
          let session = ($name | default "default")
          zellij attach -c $session
        }

        def za [name?: string] {
          let session = ($name | default "default")
          zellij attach $session
        }

        def edit [name?: string] {
          let sessionName = if $name != null { $name } else { repo-name }

          if ($sessionName != null) {
            zellij -l dev attach -c $sessionName
          } else {
            zellij -l dev
          }
        }
      '';
    };
  };

  xdg.configFile."zellij/layouts" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/dev/multiplexer/layouts";
  };
}
