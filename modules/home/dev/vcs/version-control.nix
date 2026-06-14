{
  config,
  lib,
  pkgs,
  ...
}: let
  scriptDir = "${config.homeModuleDir}/dev/vcs/scripts";
in {
  home.packages = with pkgs; [
    # Neat TUI for jujutsu
    # https://github.com/Cretezy/lazyjj
    lazyjj

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
      shellAliases.ljj = "lazyjj";
    };

    ssh = {
      enable = true;
      enableDefaultConfig = false;

      extraConfig = lib.optionalString pkgs.stdenv.isDarwin ''
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
    zsh.shellAliases = {
      lg = "lazygit";
      ljj = "lazyjj";
    };
    fish = {
      shellAliases = {
        lg = "lazygit";
        ljj = "lazyjj";
      };
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
