{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: let
  niriDir = "${config.homeModuleDir}/graphical-nixos/niri";

  niriBinds = ''
    binds {
      ${lib.concatMapStringsSep "\n      " (
      b: let
        args =
          if b.niriArgs != null
          then " ${b.niriArgs}"
          else "";
        desc =
          if b.description != null
          then " hotkey-overlay-title=\"${b.description}\""
          else "";
      in "${config.home.desktop.wm.lib.toNiriKey b.key}${desc}${args} { ${b.niri} }"
    ) (lib.filter (b: b.niri != null) config.home.desktop.wm.keybinds)}
    }
  '';
in {
  imports = [
    inputs.dankMaterialShell.homeModules.niri
    ../../desktop/wm/shared-keybinds.nix
  ];

  config = {
    programs = {
      dank-material-shell.niri = {
        enableKeybinds = true;
        enableSpawn = true;
        # https://github.com/AvengeMedia/DankMaterialShell/pull/1239/files
        includes.enable = false;
      };

      niri = {
        package = pkgs.niri;
        config = null;
      };
    };

    stylix.targets.niri.enable = false;

    xdg = {
      portal.xdgOpenUsePortal = true;
      configFile = {
        "niri/config.kdl".source = config.lib.file.mkOutOfStoreSymlink "${niriDir}/config.kdl";
        "niri/dms".source = config.lib.file.mkOutOfStoreSymlink "${niriDir}/dms";
        "niri/dms-overrides.kdl".source = config.lib.file.mkOutOfStoreSymlink "${niriDir}/dms-overrides.kdl";
        "niri/generated-binds.kdl".text = niriBinds;
      };
    };
  };
}
