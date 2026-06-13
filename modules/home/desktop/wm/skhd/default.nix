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
  unsupportedSkhdKeys = [
    "xf86launch1"
    "ctrl-xf86launch1"
    "alt-xf86launch1"
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
    services.skhd = {
      enable = true;
      errorLogFile = "${config.home.homeDirectory}/Library/Logs/skhd.err.log";
      outLogFile = "${config.home.homeDirectory}/Library/Logs/skhd.out.log";

      config = skhdBinds;
    };
  };
}
