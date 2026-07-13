{
  config,
  lib,
  pkgs,
  ...
}: let
  omniwmStateDir = "${config.home.homeDirectory}/Library/Caches/sketchybar-omniwm";
  launchdPath = lib.concatStringsSep ":" [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
    "${config.home.homeDirectory}/.nix-profile/bin"
    "/etc/profiles/per-user/${config.home.username}/bin"
    "/run/current-system/sw/bin"
    "/nix/var/nix/profiles/default/bin"
    (lib.makeBinPath [pkgs.jq])
    "/usr/local/bin"
    "/usr/bin"
    "/bin"
    "/usr/sbin"
    "/sbin"
  ];
in {
  config = lib.mkIf pkgs.stdenv.isDarwin {
    launchd.agents.sketchybar-omniwm-watch = {
      # Disabled in preference to built-in OmniWM bar
      enable = false;
      config = {
        ProgramArguments = [
          "${config.home.homeDirectory}/.config/sketchybar/plugins/omniwm.sh"
          "watch"
        ];
        RunAtLoad = true;
        KeepAlive = true;
        WorkingDirectory = config.home.homeDirectory;
        EnvironmentVariables = {
          CONFIG_DIR = "${config.home.homeDirectory}/.config/sketchybar";
          PLUGIN_DIR = "${config.home.homeDirectory}/.config/sketchybar/plugins";
          SKETCHYBAR_BIN = "${pkgs.sketchybar}/bin/sketchybar";
          SKETCHYBAR_OMNIWM_STATE_DIR = omniwmStateDir;
          PATH = launchdPath;
        };
        StandardOutPath = "${config.home.homeDirectory}/Library/Logs/sketchybar-omniwm-watch.log";
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/sketchybar-omniwm-watch.log";
      };
    };

    programs.sketchybar = {
      # Rely on OmniWM inbuilt bar
      enable = false;
      extraPackages = [pkgs.jq];
      service.enable = false;
    };

    xdg.configFile."sketchybar/sketchybarrc" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/desktop/wm/sketchybar/sketchybar.sh";
    };
    xdg.configFile."sketchybar/plugins" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/desktop/wm/sketchybar/plugins";
    };
  };
}
