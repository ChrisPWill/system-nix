{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types;

  scriptDir = "${config.homeModuleDir}/desktop/wm/scripts";
  togglePinned = "${scriptDir}/toggle-pinned";

  toggleAppType = types.submodule {
    options = {
      key = mkOption {
        type = types.str;
        description = "Shared keybinding used to toggle this app.";
      };

      appId = mkOption {
        type = types.str;
        description = "Window/app identifier matched by toggle-pinned.";
      };

      command = mkOption {
        type = types.str;
        description = "Command used to launch the app when it is not already running.";
      };

      description = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Description shown in keybinding overlays.";
      };

      niriTitle = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Optional niri window title matcher passed to toggle-pinned.";
      };

      omniTitle = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Optional macOS application/title matcher passed to toggle-pinned.";
      };

      floating = mkOption {
        type = types.bool;
        default = true;
        description = "Whether the app should float when pulled back to the current workspace.";
      };
    };
  };

  niriSpawn = args: ''spawn ${lib.concatMapStringsSep " " builtins.toJSON args};'';

  titleArgs = app: title:
    if title != null
    then [title]
    else lib.optional (!app.floating) "";

  toggleArgs = app: title:
    [
      "toggle-pinned"
      app.appId
      app.command
    ]
    ++ titleArgs app title
    ++ lib.optional (!app.floating) "false";

  omniArgs = app:
    [
      togglePinned
      app.appId
      app.command
    ]
    ++ titleArgs app app.omniTitle
    ++ lib.optional (!app.floating) "false";

  mkToggleKeybind = _name: app: {
    inherit (app) key description;
    niri = niriSpawn (toggleArgs app app.niriTitle);
    omni = lib.escapeShellArgs (omniArgs app);
  };
in {
  options.home.desktop.wm.toggleApps = mkOption {
    type = types.attrsOf toggleAppType;
    default = {};
    description = "Applications that can be toggled between the pinned workspace and the current workspace.";
  };

  config = {
    home.desktop.wm.toggleApps =
      lib.optionalAttrs (!config.isPersonalMachine) {
        discord = {
          key = "cmd+alt+ctrl-d";
          appId = "discord";
          command = "Discord";
          omniTitle = "Discord";
          description = "Toggle Discord";
        };

        signal = {
          key = "cmd+alt+ctrl-s";
          appId = "signal";
          command = "signal-desktop";
          omniTitle = "Signal";
          description = "Toggle Signal";
        };
      }
      // {
        obsidian = {
          key = "cmd+alt+ctrl-o";
          appId = "electron";
          command = "obsidian";
          niriTitle = "Obsidian";
          omniTitle = "Obsidian";
          description = "Toggle Obsidian";
        };

        logseq = {
          key = "cmd+alt+ctrl-backslash";
          appId = "logseq";
          command = "logseq";
          niriTitle = "logseq";
          omniTitle = "Logseq";
          description = "Toggle LogSeq";
        };
      };

    home.desktop.wm.keybinds =
      lib.mapAttrsToList mkToggleKeybind config.home.desktop.wm.toggleApps;
  };
}
