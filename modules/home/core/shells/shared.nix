# Common shell configuration shared across Zsh, Fish, and Nushell.
# This includes aliases, prompt settings (Starship), and shared CLI tools.
{
  config,
  lib,
  pkgs,
  ...
}: let
  commonAliases = {
    # NixOS/Darwin switch aliases
    hms = lib.mkIf config.programs.home-manager.enable "home-manager switch --flake ${config.nixConfigDir}/.";
    drs = lib.mkIf pkgs.stdenv.isDarwin "sudo /run/current-system/sw/bin/darwin-rebuild switch --flake ${config.nixConfigDir}/.";
    nrs = lib.mkIf (pkgs.stdenv.isLinux && !config.programs.home-manager.enable) "sudo nixos-rebuild switch --flake ${config.nixConfigDir}/.";

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
    # Apply aliases to shells
    programs.zsh.shellAliases = commonAliases // zshSpecificAliases;
    programs.fish.shellAliases = commonAliases;
    programs.nushell.shellAliases = commonAliases;

    # Shared shell-related programs
    programs.starship.enable = true;
    programs.starship.settings = {
      format = "$all$custom$character";
      right_format = "$os$shell$memory_usage";
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
        when = "jj root --quiet";
        command = "jj log -r @ --no-graph --ignore-working-copy --color never -T 'change_id.shortest(8)'";
        shell = ["zsh"];
        symbol = "jj ";
        style = "bold purple";
        format = "[$symbol$output]($style) ";
      };
    };
  };
}
