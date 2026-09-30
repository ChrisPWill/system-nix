{
  config,
  lib,
  pkgs,
  ...
}: let
  scriptDir = "${config.homeModuleDir}/dev/vcs/scripts";
  # Kept as a stub so muscle memory gets a pointer instead of "command not found".
  ljjReplacedMessage = "ljj (lazyjj) has been replaced by jjui. Run `jjui`, or press Alt-g.";
in {
  home.packages = with pkgs; [
    # Another fancy git UI
    tig
  ];

  home.sessionPath = [scriptDir];
  programs = {
    nushell = {
      extraEnv = ''
        $env.PATH = ($env.PATH | split row (char esep) | append "${scriptDir}")
      '';
      shellAliases.lg = "lazygit";
      shellAliases.ljj = "print '${ljjReplacedMessage}'";
      extraConfig = ''
        $env.config = (
          $env.config
          | upsert keybindings (
              $env.config.keybindings
              | append [
                  {
                      name: open_vcs,
                      modifier: Alt,
                      keycode: char_g,
                      mode: [vi_normal, vi_insert, emacs],
                      event: {
                          send: executehostcommand,
                          cmd: "open-vcs"
                      }
                  }
              ]
          )
        )
      '';
    };

    # Neat TUI for jujutsu
    # https://github.com/idursun/jjui
    jjui.enable = true;

    ssh = {
      enable = true;
      enableDefaultConfig = false;

      extraConfig = lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
        IgnoreUnknown UseKeychain
        UseKeychain yes
      '';

      settings = {
        "*" = {
          AddKeysToAgent = "yes";
          Compression = true;
          ForwardAgent = true;
          ServerAliveCountMax = 2;
          ServerAliveInterval = 300;
        };
      };
    };

    git = {
      enable = true;

      lfs.enable = true;

      settings = {
        user.name = "Chris Williams";
        user.email = config.userEmail;
        push.autoSetupRemote = true;
        core = {
          # Improved performance on MacOS
          # https://github.blog/2022-06-29-improve-git-monorepo-performance-with-a-file-system-monitor/
          fsmonitor = true;
          untrackedcache = true;
        };
      };
    };

    diff-so-fancy.enable = true;

    # Neat TUI for git
    # https://github.com/jesseduffield/lazygit
    lazygit.enable = true;
    zsh = {
      shellAliases = {
        lg = "lazygit";
        ljj = "echo '${ljjReplacedMessage}'";
      };
      initContent = ''
        open-vcs-widget() {
          zle -I
          open-vcs < /dev/tty
          zle reset-prompt
        }

        zle -N open-vcs-widget

        typeset -ga zvm_after_init_commands
        zvm_after_init_commands+=("zvm_bindkey viins '^[g' open-vcs-widget")
      '';
    };
    fish = {
      shellAliases = {
        lg = "lazygit";
        ljj = "echo '${ljjReplacedMessage}'";
      };
      interactiveShellInit = lib.mkAfter ''
        for mode in default insert
            bind --mode $mode \eg 'open-vcs; commandline -f repaint'
        end
      '';
      shellAbbrs = {
        jjrm = "jj rebase -s @ -d master@origin";
        jjnm = {
          expansion = "jj new master@origin -m \"%\"";
          setCursor = true;
        };
      };
    };

    # https://jj-vcs.github.io/jj/latest/
    # VCS built on top of git
    # Experimenting with this for personal projects
    jujutsu = {
      enable = true;
      settings = {
        user.name = "Chris Williams";
        user.email = config.userEmail;

        fix.tools = {
          "1-treefmt" = {
            command = ["nix" "fmt" "--" "--stdin" "$path"];
            patterns = ["glob:**/*"];
          };

          "2-statix" = {
            command = ["${pkgs.statix}/bin/statix" "fix" "--stdin" "--config" "$root"];
            patterns = ["glob:**/*.nix"];
          };

          "3-deadnix" = {
            command = [
              "sh"
              "-c"
              ''
                tmp="$(mktemp "''${TMPDIR:-/tmp}/jj-deadnix.XXXXXX.nix")"
                trap 'rm -f "$tmp"' EXIT

                cat > "$tmp"
                ${pkgs.deadnix}/bin/deadnix --edit --quiet "$tmp" >/dev/null
                cat "$tmp"
              ''
            ];
            patterns = ["glob:**/*.nix"];
          };
        };
      };
    };
  };

  services.ssh-agent.enable = true;
}
