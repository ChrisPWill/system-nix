{
  config,
  lib,
  pkgs,
  ...
}: let
  commandPath = lib.concatStringsSep ":" [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
    "/etc/profiles/per-user/${config.home.username}/bin"
    "/run/current-system/sw/bin"
    "/nix/var/nix/profiles/default/bin"
    "$PATH"
  ];
  skhdBinary = "/Library/Application Support/Skhd/skhd";
  unsupportedSkhdKeys = [
    "xf86launch1"
    "ctrl-xf86launch1"
    "alt-xf86launch1"
    "print"
    "ctrl-print"
    "alt-print"
    "fn-f10"
    "fn-f11"
    "fn-f12"
  ];

  # Generate skhdrc strings for all binds with an `omni` action
  skhdBinds = lib.concatMapStringsSep "\n" (
    b: "${config.home.desktop.wm.lib.toSkhdKey b.key} : PATH=${commandPath} ${b.omni}"
  ) (lib.filter (b: b.omni != null && !(builtins.elem b.key unsupportedSkhdKeys)) config.home.desktop.wm.keybinds);
in {
  imports = [
    ../shared-keybinds.nix
  ];

  config = lib.mkIf pkgs.stdenv.isDarwin {
    home.packages = [pkgs.skhd];

    xdg.configFile."skhd/skhdrc".text = skhdBinds;

    launchd.agents.skhd = {
      enable = true;
      config = {
        ProgramArguments = [
          skhdBinary
        ];
        RunAtLoad = true;
        KeepAlive = true;
        ProcessType = "Interactive";
        EnvironmentVariables = {
          PATH = commandPath;
        };
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/skhd.err.log";
        StandardOutPath = "${config.home.homeDirectory}/Library/Logs/skhd.out.log";
      };
    };
  };
}
