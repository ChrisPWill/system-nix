{
  config,
  lib,
  pkgs,
  ...
}: let
  workspaces =
    (map (workspace: {
        key = workspace;
        name = workspace;
      })
      ["1" "2" "3" "4" "5" "6" "7" "8" "9"])
    ++ [
      {
        key = "q";
        name = "10";
      }
      {
        key = "w";
        name = "11";
      }
      {
        key = "e";
        name = "12";
      }
      {
        key = "a";
        name = "13";
      }
      {
        key = "s";
        name = "14";
      }
      {
        key = "d";
        name = "15";
      }
    ];

  commandPath = lib.concatStringsSep ":" [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
    "/etc/profiles/per-user/${config.home.username}/bin"
    "/run/current-system/sw/bin"
    "/nix/var/nix/profiles/default/bin"
    "$PATH"
  ];
  run = command: "PATH=${commandPath} ${command}";
  omni = command: run "omniwmctl command ${command}";
  openApp = application: run "open -a ${lib.escapeShellArg application}";
  openUrl = url: run "open ${lib.escapeShellArg url}";
  script = name: lib.escapeShellArg "${config.homeModuleDir}/scripts/${name}";
  osascript = expression: run "osascript -e ${lib.escapeShellArg expression}";
  lockScreen = run "${lib.escapeShellArg "/System/Library/CoreServices/Menu Extras/User.menu/Contents/Resources/CGSession"} -suspend";

  workspaceBindings =
    lib.concatMapStringsSep "\n" (workspace: "cmd + alt - ${workspace.key} : ${omni "switch-workspace ${workspace.name}"}")
    workspaces;

  moveWorkspaceBindings =
    lib.concatMapStringsSep "\n" (workspace: "cmd + alt + shift - ${workspace.key} : ${omni "move-column-to-workspace ${workspace.name}"}")
    workspaces;
in {
  config = lib.mkIf pkgs.stdenv.isDarwin {
    services.skhd = {
      enable = true;
      errorLogFile = "${config.home.homeDirectory}/Library/Logs/skhd.err.log";
      outLogFile = "${config.home.homeDirectory}/Library/Logs/skhd.out.log";

      config = ''
        # Top-level actions
        cmd + alt - t : ${run "wezterm start"}
        cmd + alt - tab : ${omni "toggle-overview"}
        # 0x2C is the keycode for '/' on most macOS layouts.
        cmd + alt + shift - 0x2C : ${omni "open-command-palette"}
        cmd + alt - r : ${openApp "Raycast"}
        cmd + alt - b : ${openApp "Firefox Developer Edition"}
        cmd + alt - v : ${openUrl "raycast://extensions/raycast/clipboard-history/clipboard-history"}
        cmd + alt - m : ${openApp "Activity Monitor"}
        # 0x2B is the keycode for ',' on most macOS layouts.
        cmd + alt - 0x2B : ${openApp "System Settings"}
        cmd + alt - p : ${omni "switch-workspace 15"}
        # 0x2A is the keycode for 'backslash' on most macOS layouts.
        # It is used for toggle-pinned logseq.
        cmd + alt - 0x2A : ${run "${script "toggle-pinned"} logseq logseq Logseq"}
        cmd + alt - o : ${run "${script "toggle-pinned"} electron obsidian Obsidian"}
        cmd + alt + ctrl - d : ${run "${script "toggle-pinned"} discord Discord Discord"}
        cmd + alt + ctrl - s : ${run "${script "toggle-pinned"} signal Signal Signal"}

        # System controls
        ctrl + alt - l : ${lockScreen}
        ctrl + alt - 0x33 : ${openApp "Activity Monitor"}
        cmd + alt + shift - p : ${run "pmset displaysleepnow"}

        # Window focus
        cmd + alt - h : ${omni "focus left"}
        cmd + alt - j : ${omni "focus down"}
        cmd + alt - k : ${omni "focus up"}
        cmd + alt - l : ${omni "focus right"}
        cmd + alt - left : ${omni "focus left"}
        cmd + alt - down : ${omni "focus down"}
        cmd + alt - up : ${omni "focus up"}
        cmd + alt - right : ${omni "focus right"}
        cmd + alt - home : ${omni "focus-column first"}
        cmd + alt - end : ${omni "focus-column last"}

        # Workspace focus
        ${workspaceBindings}
        cmd + alt - u : ${omni "switch-workspace next"}
        cmd + alt - pagedown : ${omni "switch-workspace next"}
        cmd + alt - i : ${omni "switch-workspace prev"}
        cmd + alt - pageup : ${omni "switch-workspace prev"}

        # Window movement
        # 0x33 is the keycode for Delete/Backspace on most macOS layouts.
        cmd + alt - 0x33 : ${osascript ''tell application "System Events" to keystroke "w" using command down''}
        cmd + alt + shift - h : ${omni "move-column left"}
        cmd + alt + shift - j : ${omni "move-window-down"}
        cmd + alt + shift - k : ${omni "move-window-up"}
        cmd + alt + shift - l : ${omni "move-column right"}
        cmd + alt + shift - left : ${omni "move-column left"}
        cmd + alt + shift - down : ${omni "move-window-down"}
        cmd + alt + shift - up : ${omni "move-window-up"}
        cmd + alt + shift - right : ${omni "move-column right"}
        cmd + alt + ctrl - home : ${omni "move-column-to-first"}
        cmd + alt + ctrl - end : ${omni "move-column-to-last"}

        # Sizing and layout
        cmd + alt - f : ${omni "toggle-column-full-width"}
        cmd + alt + shift - f : ${omni "toggle-fullscreen"}
        cmd + alt + shift - t : ${omni "toggle-focused-window-floating"}
        cmd + alt + ctrl - w : ${omni "toggle-column-tabbed"}
        cmd + alt - space : ${omni "cycle-column-width forward"}
        cmd + alt + shift - space : ${omni "cycle-window-height forward"}
        cmd + alt + ctrl - r : ${omni "reset-window-height"}
        cmd + alt + ctrl - f : ${omni "expand-column-to-available-width"}
        cmd + alt - c : ${omni "center-column"}
        cmd + alt + ctrl - c : ${omni "center-visible-columns"}
        # 0x21, 0x1E, 0x2F, 0x1B, and 0x18 are [, ], ., -, and = on most macOS layouts.
        cmd + alt - 0x21 : ${omni "consume-or-expel-window-left"}
        cmd + alt - 0x1E : ${omni "consume-or-expel-window-right"}
        cmd + alt - 0x2F : ${omni "expel-window-from-column"}
        cmd + alt - 0x1B : ${omni "set-column-width -10%"}
        cmd + alt - 0x18 : ${omni "set-column-width +10%"}
        cmd + alt + shift - 0x1B : ${omni "set-window-height -10%"}
        cmd + alt + shift - 0x18 : ${omni "set-window-height +10%"}

        # Move columns to workspaces
        ${moveWorkspaceBindings}
        cmd + alt + ctrl - down : ${omni "move-column-to-workspace down"}
        cmd + alt + ctrl - u : ${omni "move-column-to-workspace down"}
        cmd + alt + ctrl - up : ${omni "move-column-to-workspace up"}
        cmd + alt + ctrl - i : ${omni "move-column-to-workspace up"}

        # Monitor movement
        cmd + alt + ctrl - h : ${omni "focus-monitor prev"}
        cmd + alt + ctrl - l : ${omni "focus-monitor next"}
        cmd + alt + ctrl - left : ${omni "focus-monitor prev"}
        cmd + alt + ctrl - right : ${omni "focus-monitor next"}
        cmd + alt + shift + ctrl - h : ${omni "swap-workspace-with-monitor left"}
        cmd + alt + shift + ctrl - l : ${omni "swap-workspace-with-monitor right"}
        cmd + alt + shift + ctrl - left : ${omni "swap-workspace-with-monitor left"}
        cmd + alt + shift + ctrl - right : ${omni "swap-workspace-with-monitor right"}

        # Media and system controls
        fn - f10 : ${osascript "set volume output muted not (output muted of (get volume settings))"}
        fn - f11 : ${osascript "set volume output volume (output volume of (get volume settings) - 5)"}
        fn - f12 : ${osascript "set volume output volume (output volume of (get volume settings) + 5)"}
      '';
    };
  };
}
