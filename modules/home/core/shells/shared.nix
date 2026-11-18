# Common shell configuration shared across Zsh, Fish, and Nushell.
# This includes aliases, prompt settings (Starship), and shared CLI tools.
{
  config,
  lib,
  pkgs,
  ...
}: let
  commonAliases = {
    # Common directory navigation
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
  };

  darwinAliases = lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
    cafe = "caffeinate -d -t 5400";
  };

  # The OS can't change while a shell runs, so bake its symbol into the prompt
  # instead of using starship's `os` module, which runs `sw_vers` every prompt.
  osSymbol =
    if pkgs.stdenv.hostPlatform.isDarwin
    then " "
    else if pkgs.stdenv.hostPlatform.isLinux
    then " "
    else "";

  # Starship runs each language's tool (`java -version`, ...) on every prompt
  # to print its version, and caches nothing. Through mise shims that costs
  # 100ms or more. mise owns versions, so show only the icon: a module runs the
  # tool only when `$version` appears in its format.
  versionlessModules = [
    "java"
    "kotlin"
    "gradle"
    "python"
    "nodejs"
    "ruby"
    "golang"
    "rust"
    "lua"
    "bun"
    "deno"
  ];

  # `jj log` takes ~80ms in a large repository, but the change id only moves
  # when a jj operation runs. Cache it per repository, keyed on the current
  # operation head (the file name under op_heads/heads).
  jjPrompt = ''
    d=$PWD
    while [ ! -d "$d/.jj" ]; do
      [ -z "$d" ] || [ "$d" = / ] && exit 0
      d=''${d%/*}
    done
    # Secondary workspaces keep .jj/repo as a file; there is no op head to key
    # on, so ask jj every time rather than risk a stale id.
    op=none
    if [ -d "$d/.jj/repo/op_heads/heads" ]; then
      set -- "$d"/.jj/repo/op_heads/heads/*
      op=''${1##*/}
    fi
    cache=''${XDG_CACHE_HOME:-$HOME/.cache}/starship-jj/''${d//\//_}
    if [ "$op" != none ] && [ -r "$cache" ] && read -r cached_op id < "$cache" && [ "$cached_op" = "$op" ]; then
      :
    else
      id=$(jj log -r @ --no-graph --ignore-working-copy --color never -T 'change_id.shortest(8)' 2>/dev/null) || exit 0
      if [ "$op" != none ]; then
        mkdir -p "''${cache%/*}" && printf '%s %s\n' "$op" "$id" > "$cache"
      fi
    fi
    printf 'jj %s ' "$id"
  '';

  # Aliases that only work or make sense in Zsh
  zshSpecificAliases = {
    "-- -" = "cd -";
    "-- --" = "cd -2";
    "-- ---" = "cd -3";
  };
in {
  config = {
    home.sessionPath = ["${config.home.homeDirectory}/.local/bin"];

    programs = {
      # Apply aliases to shells
      zsh.shellAliases = commonAliases // darwinAliases // zshSpecificAliases;
      fish.shellAliases = commonAliases // darwinAliases;
      nushell.shellAliases = commonAliases // darwinAliases;

      # Shared shell-related programs
      starship = {
        enable = config.appApproved.starship;
        settings = lib.genAttrs versionlessModules (_: {format = "[$symbol]($style) ";}) // {
          format = "$all$character";
          right_format = "$git_branch$git_commit$custom ${osSymbol}$shell";
          # Old format - can re-add once git is more optimised
          # right_format = "$os$shell$git_status$git_metrics$memory_usage";
          # Above jj's ~80ms cache-miss time.
          command_timeout = 200;
          scan_timeout = 10;
          cmd_duration.min_time = 200;
          direnv = {
            disabled = false;
            format = "[$symbol$loaded/$allowed]($style) ";
          };
          # Disabled git prompt to improve performance
          git_metrics.disabled = true;
          git_status.disabled = true;
          nix_shell = {
            heuristic = true;
            impure_msg = "impure";
            pure_msg = "pure";
            unknown_msg = "nix";
            format = "[$symbol$state( \\($name\\))]($style) ";
          };
          memory_usage.disabled = true;
          directory.truncate_to_repo = false;
          os.disabled = true;
          shell.disabled = false;
          status.disabled = false;
          custom.jj = {
            when = true;
            command = jjPrompt;
            # bare bash: zsh would source ~/.config/zsh/.zshenv on every prompt.
            shell = ["bash" "--noprofile" "--norc"];
            symbol = "";
            style = "bold purple";
            format = "[$output]($style)";
          };
        };
      };
    };
  };
}
