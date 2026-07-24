# Common shell configuration shared across Zsh, Fish, and Nushell.
# This includes aliases, prompt settings (Starship), and shared CLI tools.
{config, ...}: let
  commonAliases = {
    # Common directory navigation
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
  };

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
      zsh.shellAliases = commonAliases // zshSpecificAliases;
      fish.shellAliases = commonAliases;
      nushell.shellAliases = commonAliases;

      # Shared shell-related programs
      starship = {
        enable = true;
        settings = {
          format = "$all$character";
          right_format = "$git_branch$git_commit$custom $os$shell$memory_usage";
          # Old format - can re-add once git is more optimised
          # right_format = "$os$shell$git_status$git_metrics$memory_usage";
          command_timeout = 100;
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
          memory_usage.disabled = false;
          memory_usage.threshold = 90;
          os.disabled = false;
          os.symbols = {
            Macos = " ";
            NixOS = " ";
            Windows = " ";
          };
          shell.disabled = false;
          status.disabled = false;
          custom.jj = {
            when = true;
            command = "id=$(jj log -r @ --no-graph --ignore-working-copy --color never -T 'change_id.shortest(8)' 2>/dev/null) && printf 'jj %s ' \"$id\"";
            shell = ["zsh"];
            symbol = "";
            style = "bold purple";
            format = "[$output]($style)";
          };
        };
      };
    };
  };
}
