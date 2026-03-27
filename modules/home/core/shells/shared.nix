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
      right_format = "$os$shell$git_status$git_metrics$memory_usage";
      command_timeout = 1000;
      cmd_duration.min_time = 200;
      git_metrics.disabled = false;
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
    };

    programs.zoxide.enable = true;
    programs.atuin.enable = true;
    programs.direnv.enable = true;
    programs.carapace.enable = true;
    programs.bat.enable = true;

    programs.eza = {
      enable = true;
      git = true;
      icons = "auto";
    };
  };
}
