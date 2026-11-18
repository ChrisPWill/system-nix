{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  scriptDir = "${config.homeModuleDir}/dev/vcs/scripts";
  approved = config.appApproved;
  # The upstream derivation leaves out pkg-config and oniguruma, which nixpkgs'
  # Rust build hooks make the onig_sys crate look for, so it fails to build.
  omnidiff = inputs.omnidiff.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [pkgs.pkg-config];
    buildInputs = (old.buildInputs or []) ++ [pkgs.oniguruma];
  });

  # jj captures a diff tool's stdout to feed its own pager, so a full-screen
  # program started as a plain tool has nothing to draw on. Run it on the
  # terminal by its real device name instead: some TUI libraries (crossterm on
  # macOS) can't poll /dev/tty itself.
  jjTtyTool = pkgs.writeShellScript "jj-tty-tool" ''
    tty=$(ps -o tty= -p $$ | tr -d ' ')
    case "$tty" in
      "" | "?" | "??") dev=/dev/tty ;;
      *) dev=/dev/$tty ;;
    esac
    "$@" <"$dev" >"$dev" 2>"$dev" || true
  '';

in {
  home.packages =
    config.filterApproved {
      # Another fancy git UI
      inherit (pkgs) tig;
    }
    ++ lib.optionals approved.omnidiff [omnidiff];

  home.sessionPath = [scriptDir];
  programs = {
    nushell = {
      shellAliases.lg = "lazygit";
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
    jjui.enable = approved.jjui;

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
      enable = approved.git;

      lfs.enable = approved.git-lfs;

      settings = {
        user.name = "Chris Williams";
        user.email = config.userEmail;
        push.autoSetupRemote = true;
        # `git dt` opens every changed file in one Neovim session; `git diff`
        # stays on delta because a pager can't host a full-screen editor.
        alias.dt = lib.mkIf approved.neovim "difftool -d";
        diff.tool = lib.mkIf approved.neovim "nvim-difftool";
        difftool.prompt = false;
        difftool.nvim-difftool.cmd = lib.mkIf approved.neovim ''nvim -c "packadd nvim.difftool" -c "DiffTool $LOCAL $REMOTE"'';
        core = {
          # Improved performance on MacOS
          # https://github.blog/2022-06-29-improve-git-monorepo-performance-with-a-file-system-monitor/
          fsmonitor = true;
          untrackedcache = true;
        };
      };
    };

    # Pager for git diff/log/show and lazygit.
    # https://github.com/dandavison/delta
    delta = {
      enable = approved.delta;
      enableGitIntegration = true;
      options = {
        navigate = true;
        line-numbers = true;
      };
    };

    # Neat TUI for git
    # https://github.com/jesseduffield/lazygit
    lazygit = {
      enable = approved.lazygit;
      settings.git.paging = lib.mkIf approved.delta {
        colorArg = "always";
        pager = "delta --dark --paging=never";
      };
    };
    zsh = {
      shellAliases = {
        lg = "lazygit";
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
      enable = approved.jujutsu;
      settings = {
        user.name = "Chris Williams";
        user.email = config.userEmail;

        ui = lib.mkIf approved.delta {
          # delta reads git-format diffs.
          diff-formatter = ":git";
          pager = "delta";
        };

        merge-tools.omnidiff = lib.mkIf approved.omnidiff {
          program = "${omnidiff}/bin/omnidiff";
          diff-args = ["$left" "$right"];
          diff-invocation-mode = "file-by-file";
        };
        # jj's default invocation mode hands the tool both directory trees.
        merge-tools.nvim-difftool = lib.mkIf approved.neovim {
          program = "${jjTtyTool}";
          diff-args = ["nvim" "-c" "packadd nvim.difftool" "-c" "DiffTool $left $right"];
        };
        # `jj dt` is the interactive viewer; plain `jj diff` stays on delta.
        aliases.dt = lib.mkIf approved.neovim ["diff" "--no-pager" "--tool" "nvim-difftool"];

        fix.tools =
          {
            "1-treefmt" = {
              command = ["nix" "fmt" "--" "--stdin" "$path"];
              patterns = ["glob:**/*"];
            };
          }
          // lib.optionalAttrs approved.statix {
            "2-statix" = {
              command = ["${pkgs.statix}/bin/statix" "fix" "--stdin" "--config" "$root"];
              patterns = ["glob:**/*.nix"];
            };
          }
          // lib.optionalAttrs approved.deadnix {
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

  services.ssh-agent.enable = approved.ssh-agent;
}
