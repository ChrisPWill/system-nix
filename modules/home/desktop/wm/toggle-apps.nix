{
  config,
  lib,
  ...
}: let
  # To add a toggle for an app that is already running:
  # - NixOS/niri: run `niri msg --json windows` and use the target window's
  #   `app_id` for niri.appId. Use `title` only when app_id is too broad.
  # - macOS/OmniWM: run `omniwmctl query windows --format json` and inspect the
  #   target window's `app.name`, `app.bundleId`, and `title`. Use the stable
  #   app/name or bundle identifier for omni.appId, and the macOS app name/title
  #   for omni.title.
  # - command is the platform-specific launch command used when the app is not
  #   running. Prefer the Linux binary name on niri; on macOS this can be the
  #   application name used by `open -a` when there is no matching command on PATH.
  inherit (lib) mkOption types;

  scriptDir = "${config.homeModuleDir}/desktop/wm/scripts";
  togglePinned = "${scriptDir}/toggle-pinned";

  toggleTargetType = types.submodule {
    options = {
      appId = mkOption {
        type = types.str;
        description = "Window/app identifier matched by toggle-pinned.";
      };

      command = mkOption {
        type = types.str;
        description = "Command used to launch the app when it is not already running.";
      };

      title = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Optional title matcher passed to toggle-pinned.";
      };
    };
  };

  toggleAppType = types.submodule {
    options = {
      key = mkOption {
        type = types.str;
        description = "Shared keybinding used to toggle this app.";
      };

      description = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Description shown in keybinding overlays.";
      };

      niri = mkOption {
        type = types.nullOr toggleTargetType;
        default = null;
        description = "niri-specific app match and launch settings.";
      };

      omni = mkOption {
        type = types.nullOr toggleTargetType;
        default = null;
        description = "OmniWM-specific app match and launch settings.";
      };

      floating = mkOption {
        type = types.bool;
        default = true;
        description = "Whether the app should float when pulled back to the current workspace.";
      };
    };
  };

  niriSpawn = args: ''spawn ${lib.concatMapStringsSep " " builtins.toJSON args};'';

  titleArgs = floating: title:
    if title != null
    then [title]
    else lib.optional (!floating) "";

  targetArgs = target: floating:
    [
      target.appId
      target.command
    ]
    ++ titleArgs floating target.title
    ++ lib.optional (!floating) "false";

  hasTarget = app: app.niri != null || app.omni != null;

  mkToggleKeybind = _name: app: {
    inherit (app) key description;
    niri =
      if app.niri != null
      then niriSpawn (["toggle-pinned"] ++ targetArgs app.niri app.floating)
      else null;
    omni =
      if app.omni != null
      then lib.escapeShellArgs ([togglePinned] ++ targetArgs app.omni app.floating)
      else null;
  };
in {
  options.home.desktop.wm.toggleApps = mkOption {
    type = types.attrsOf toggleAppType;
    default = {};
    description = "Applications that can be toggled between the pinned workspace and the current workspace.";
  };

  config = {
    home.desktop.wm.toggleApps =
      lib.optionalAttrs config.isPersonalMachine {
        discord = {
          key = "cmd+alt+ctrl-d";
          description = "Toggle Discord";
          niri = {
            appId = "discord";
            command = "Discord";
          };
          omni = {
            appId = "discord";
            command = "Discord";
            title = "Discord";
          };
        };

        signal = {
          key = "cmd+alt+ctrl-s";
          description = "Toggle Signal";
          niri = {
            appId = "signal";
            command = "signal-desktop";
          };
          omni = {
            appId = "signal";
            command = "signal-desktop";
            title = "Signal";
          };
        };
      }
      // {
        obsidian = {
          key = "cmd+alt+ctrl-o";
          description = "Toggle Obsidian";
          niri = {
            appId = "electron";
            command = "obsidian";
            title = "Obsidian";
          };
          omni = {
            appId = "electron";
            command = "obsidian";
            title = "Obsidian";
          };
        };

        logseq = {
          key = "cmd+alt+ctrl-backslash";
          description = "Toggle LogSeq";
          niri = {
            appId = "logseq";
            command = "logseq";
            title = "logseq";
          };
          omni = {
            appId = "logseq";
            command = "logseq";
            title = "Logseq";
          };
        };
      };

    home.desktop.wm.keybinds =
      lib.mapAttrsToList mkToggleKeybind (lib.filterAttrs (_name: hasTarget) config.home.desktop.wm.toggleApps);
  };
}
