{
  lib,
  config,
  ...
}: let
  inherit (lib) types mkOption;

  keybindType = types.submodule {
    options = {
      key = mkOption {type = types.str;};
      niri = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      omni = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      description = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      niriArgs = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
    };
  };

  skhdBaseMap = {
    "comma" = "0x2B";
    "slash" = "0x2C";
    "backslash" = "0x2A";
    "backspace" = "0x33";
    "delete" = "0x33";
    "bracketleft" = "0x21";
    "bracketright" = "0x1E";
    "period" = "0x2F";
    "minus" = "0x1B";
    "equal" = "0x18";
  };

  niriModMap = {
    "cmd" = "Super";
    "alt" = "Alt";
    "ctrl" = "Ctrl";
    "shift" = "Shift";
  };

  niriBaseMap = {
    "comma" = "Comma";
    "slash" = "Slash";
    "backslash" = "BackSlash";
    "backspace" = "BackSpace";
    "bracketleft" = "BracketLeft";
    "bracketright" = "BracketRight";
    "period" = "Period";
    "minus" = "Minus";
    "equal" = "Equal";
    "escape" = "Escape";
    "delete" = "Delete";
    "print" = "Print";
    "home" = "Home";
    "end" = "End";
    "left" = "Left";
    "right" = "Right";
    "up" = "Up";
    "down" = "Down";
    "page_down" = "Page_Down";
    "page_up" = "Page_Up";
    "pagedown" = "Page_Down";
    "pageup" = "Page_Up";
    "wheelscrolldown" = "WheelScrollDown";
    "wheelscrollup" = "WheelScrollUp";
    "wheelscrollleft" = "WheelScrollLeft";
    "wheelscrollright" = "WheelScrollRight";
    "xf86audioraisevolume" = "XF86AudioRaiseVolume";
    "xf86audiolowervolume" = "XF86AudioLowerVolume";
    "xf86audiomute" = "XF86AudioMute";
    "xf86audiomicmute" = "XF86AudioMicMute";
    "xf86audioplay" = "XF86AudioPlay";
    "xf86audiostop" = "XF86AudioStop";
    "xf86audionext" = "XF86AudioNext";
    "xf86audioprev" = "XF86AudioPrev";
    "xf86monbrightnessup" = "XF86MonBrightnessUp";
    "xf86monbrightnessdown" = "XF86MonBrightnessDown";
    "xf86launch1" = "XF86Launch1";
  };

  parseModifiers = keyStr: let
    parts = lib.splitString "-" keyStr;
  in
    if builtins.length parts > 1
    then lib.splitString "+" (builtins.head parts)
    else [];
  parseBaseKey = keyStr: let
    parts = lib.splitString "-" keyStr;
  in
    if builtins.length parts > 1
    then builtins.elemAt parts 1
    else keyStr;

  toSkhdKey = keyStr: let
    mods = parseModifiers keyStr;
    base = parseBaseKey keyStr;
    mappedBase =
      if builtins.hasAttr base skhdBaseMap
      then skhdBaseMap.${base}
      else base;
    modStr =
      if builtins.length mods > 0
      then builtins.concatStringsSep " + " mods + " - "
      else "";
  in "${modStr}${mappedBase}";

  toNiriKey = keyStr: let
    mods = parseModifiers keyStr;
    base = parseBaseKey keyStr;
    mappedMods = map (m:
      if builtins.hasAttr m niriModMap
      then niriModMap.${m}
      else m)
    mods;
    mappedBase =
      if builtins.hasAttr (lib.toLower base) niriBaseMap
      then niriBaseMap.${lib.toLower base}
      else if builtins.stringLength base == 1
      then lib.toUpper base
      else base;
    parts = mappedMods ++ [mappedBase];
  in
    builtins.concatStringsSep "+" parts;

  workspaceKeys = [
    {
      key = "1";
      ws = "1";
    }
    {
      key = "2";
      ws = "2";
    }
    {
      key = "3";
      ws = "3";
    }
    {
      key = "4";
      ws = "4";
    }
    {
      key = "5";
      ws = "5";
    }
    {
      key = "6";
      ws = "6";
    }
    {
      key = "7";
      ws = "7";
    }
    {
      key = "8";
      ws = "8";
    }
    {
      key = "9";
      ws = "9";
    }
    {
      key = "q";
      ws = "10";
    }
    {
      key = "w";
      ws = "11";
    }
    {
      key = "e";
      ws = "12";
    }
    {
      key = "a";
      ws = "13";
    }
    {
      key = "s";
      ws = "14";
    }
    {
      key = "d";
      ws = "15";
    }
  ];

  genWorkspaceBinds = lib.flatten (map (w: [
      {
        key = "cmd+alt-${w.key}";
        niri = "focus-workspace ${w.ws};";
        omni = "omniwmctl command switch-workspace ${w.ws}";
      }
      {
        key = "cmd+alt+shift-${w.key}";
        niri = "move-column-to-workspace ${w.ws};";
        omni = "omniwmctl command move-column-to-workspace ${w.ws}";
      }
    ])
    workspaceKeys);

  # skhd wrappers
  scriptDir = "${config.homeModuleDir}/desktop/wm/scripts";
  run = command: command;
  omni = command: run "omniwmctl command ${command}";
  openApp = application: run "open -a ${lib.escapeShellArg application}";
  firefoxDeveloperEdition = "/Applications/Firefox Developer Edition.app/Contents/MacOS/firefox";
  openUrl = url: run "open ${lib.escapeShellArg url}";
  osascript = expression: run "osascript -e ${lib.escapeShellArg expression}";
  lockScreen = run "${lib.escapeShellArg "/System/Library/CoreServices/Menu Extras/User.menu/Contents/Resources/CGSession"} -suspend";
in {
  imports = [
    ./toggle-apps.nix
  ];

  options.home.desktop.wm.keybinds = mkOption {
    type = types.listOf keybindType;
    default = [];
    description = "Shared cross-platform keybindings for skhd and niri";
  };

  options.home.desktop.wm.lib = mkOption {
    type = types.attrsOf types.anything;
    description = "Helper functions for keybinds";
    default = {};
  };

  config = {
    programs.nushell.extraEnv = ''
      $env.PATH = ($env.PATH | split row (char esep) | append "${scriptDir}")
    '';

    home = {
      sessionPath = [scriptDir];
      desktop.wm.lib = {
        inherit toSkhdKey toNiriKey;
      };

      desktop.wm.keybinds =
        [
          # Top-level actions
          {
            key = "cmd+alt-t";
            niri = ''spawn "ghostty";'';
            omni = run "wezterm start";
            description = "Open Terminal";
          }
          {
            key = "cmd+alt-tab";
            niri = "toggle-overview;";
            omni = omni "toggle-overview";
            niriArgs = "repeat=false";
          }
          {
            key = "cmd+alt+shift-slash";
            niri = "show-hotkey-overlay;";
            omni = omni "open-command-palette";
          }
          {
            key = "cmd+alt-r";
            niri = ''spawn "dms" "ipc" "call" "spotlight" "toggle";'';
            omni = openApp "Raycast";
            description = "Application Launcher";
          }
          {
            key = "cmd+alt-b";
            niri = ''spawn "vivaldi";'';
            omni = run "${lib.escapeShellArg firefoxDeveloperEdition} --new-window about:blank";
            description = "Browser";
          }
          {
            key = "cmd+alt-v";
            niri = ''spawn "dms" "ipc" "call" "clipboard" "toggle";'';
            omni = openUrl "raycast://extensions/raycast/clipboard-history/clipboard-history";
            description = "Clipboard Manager";
          }
          {
            key = "cmd+alt-m";
            niri = ''spawn "dms" "ipc" "call" "processlist" "focusOrToggle";'';
            omni = openApp "Activity Monitor";
            description = "Task Manager";
          }
          {
            key = "cmd+alt-comma";
            niri = ''spawn "dms" "ipc" "call" "settings" "focusOrToggle";'';
            omni = openApp "System Settings";
            description = "Settings";
          }
          {
            key = "cmd+alt-y";
            niri = ''spawn "dms" "ipc" "call" "dankdash" "wallpaper";'';
            description = "Browse Wallpapers";
          }
          {
            key = "cmd+alt-n";
            niri = ''spawn "dms" "ipc" "call" "notifications" "toggle";'';
            omni = osascript ''tell application "System Events" to click menu bar item "Clock" of menu bar 1 of application process "ControlCenter"'';
            description = "Notification Center";
          }
          {
            key = "cmd+alt+shift-n";
            niri = ''spawn "dms" "ipc" "call" "notepad" "toggle";'';
            omni = openUrl "raycast://extensions/raycast/raycast-notes/raycast-notes";
            description = "Notepad";
          }
          {
            key = "cmd+alt-p";
            niri = ''focus-workspace "pinned";'';
            omni = omni "switch-workspace 15";
            description = "Pinned Workspace";
          }

          # Toggles
          {
            key = "cmd+alt+ctrl-b";
            niri = ''spawn "ghostty" "--title=ghostty-floating" "-e" "btop";'';
            omni = run "wezterm start -- btop";
            description = "Open Btop";
          }
          {
            key = "cmd+alt+ctrl-y";
            niri = ''spawn "ghostty" "--title=ghostty-floating" "-e" "lazyjournal";'';
            description = "Open LazyJournal";
          }

          # Security
          {
            key = "ctrl+alt-l";
            niri = ''spawn "dms" "ipc" "call" "lock" "lock";'';
            omni = lockScreen;
            description = "Lock Screen";
          }
          {
            key = "cmd+alt+shift-p";
            niri = "power-off-monitors;";
            omni = run "pmset displaysleepnow";
          }
          {
            key = "cmd+alt+shift-escape";
            niri = "quit;";
          }

          # Window focus
          {
            key = "cmd+alt-h";
            niri = "focus-column-left;";
            omni = omni "focus left";
          }
          {
            key = "cmd+alt-j";
            niri = "focus-window-down;";
            omni = omni "focus down";
          }
          {
            key = "cmd+alt-k";
            niri = "focus-window-up;";
            omni = omni "focus up";
          }
          {
            key = "cmd+alt-l";
            niri = "focus-column-right;";
            omni = omni "focus right";
          }
          {
            key = "cmd+alt-left";
            niri = "focus-column-left;";
            omni = omni "focus left";
          }
          {
            key = "cmd+alt-down";
            niri = "focus-window-down;";
            omni = omni "focus down";
          }
          {
            key = "cmd+alt-up";
            niri = "focus-window-up;";
            omni = omni "focus up";
          }
          {
            key = "cmd+alt-right";
            niri = "focus-column-right;";
            omni = omni "focus right";
          }
          {
            key = "cmd+alt-home";
            niri = "focus-column-first;";
            omni = omni "focus-column first";
          }
          {
            key = "cmd+alt-end";
            niri = "focus-column-last;";
            omni = omni "focus-column last";
          }

          # Workspace focus
          {
            key = "cmd+alt-pagedown";
            niri = "focus-workspace-down;";
            omni = omni "switch-workspace next";
          }
          {
            key = "cmd+alt-pageup";
            niri = "focus-workspace-up;";
            omni = omni "switch-workspace prev";
          }
          {
            key = "cmd+alt-u";
            niri = "focus-workspace-down;";
            omni = omni "switch-workspace next";
          }
          {
            key = "cmd+alt-i";
            niri = "focus-workspace-up;";
            omni = omni "switch-workspace prev";
          }

          # Window movement
          {
            key = "cmd+alt-backspace";
            niri = "close-window;";
            omni = osascript ''tell application "System Events" to keystroke "w" using command down'';
            niriArgs = "repeat=false";
          }
          {
            key = "cmd+alt+shift-h";
            niri = "move-column-left;";
            omni = omni "move-column left";
          }
          {
            key = "cmd+alt+shift-j";
            niri = "move-window-down;";
            omni = omni "move down";
          }
          {
            key = "cmd+alt+shift-k";
            niri = "move-window-up;";
            omni = omni "move up";
          }
          {
            key = "cmd+alt+shift-l";
            niri = "move-column-right;";
            omni = omni "move-column right";
          }
          {
            key = "cmd+alt+shift-left";
            niri = "move-column-left;";
            omni = omni "move-column left";
          }
          {
            key = "cmd+alt+shift-down";
            niri = "move-window-down;";
            omni = omni "move down";
          }
          {
            key = "cmd+alt+shift-up";
            niri = "move-window-up;";
            omni = omni "move up";
          }
          {
            key = "cmd+alt+shift-right";
            niri = "move-column-right;";
            omni = omni "move-column right";
          }
          {
            key = "cmd+alt+ctrl-home";
            niri = "move-column-to-first;";
          }
          {
            key = "cmd+alt+ctrl-end";
            niri = "move-column-to-last;";
          }

          # Sizing and layout
          {
            key = "cmd+alt-f";
            niri = "maximize-column;";
            omni = omni "toggle-column-full-width";
          }
          {
            key = "cmd+alt+shift-f";
            niri = "fullscreen-window;";
            omni = omni "toggle-fullscreen";
          }
          {
            key = "cmd+alt+shift-t";
            niri = "toggle-window-floating;";
            omni = omni "toggle-focused-window-floating";
          }
          {
            key = "cmd+alt+shift-v";
            niri = "switch-focus-between-floating-and-tiling;";
          }
          {
            key = "cmd+alt+ctrl-t";
            niri = "toggle-column-tabbed-display;";
            omni = omni "toggle-column-tabbed";
          }
          {
            key = "cmd+alt-space";
            niri = "switch-preset-column-width;";
            omni = omni "cycle-column-width forward";
          }
          {
            key = "cmd+alt+ctrl-space";
            niri = "switch-preset-window-height;";
          }
          {
            key = "cmd+alt+ctrl-r";
            niri = "reset-window-height;";
          }
          {
            key = "cmd+alt+ctrl-f";
            niri = "expand-column-to-available-width;";
          }
          {
            key = "cmd+alt-c";
            niri = "center-column;";
          }
          {
            key = "cmd+alt+ctrl-c";
            niri = "center-visible-columns;";
          }

          # Column Management
          {
            key = "cmd+alt-bracketleft";
            niri = "consume-or-expel-window-left;";
          }
          {
            key = "cmd+alt-bracketright";
            niri = "consume-or-expel-window-right;";
          }
          {
            key = "cmd+alt-period";
            niri = ''spawn "nautilus";'';
            omni = openApp "Finder";
            description = "File Manager";
          }
          {
            key = "cmd+alt-minus";
            niri = ''set-column-width "-10%";'';
            omni = omni "resize left shrink";
          }
          {
            key = "cmd+alt-equal";
            niri = ''set-column-width "+10%";'';
            omni = omni "resize right grow";
          }
          {
            key = "cmd+alt+shift-minus";
            niri = ''set-window-height "-10%";'';
            omni = omni "resize down shrink";
          }
          {
            key = "cmd+alt+shift-equal";
            niri = ''set-window-height "+10%";'';
            omni = omni "resize up grow";
          }

          # Move columns to workspaces
          {
            key = "cmd+alt+ctrl-down";
            niri = "move-column-to-workspace-down;";
            omni = omni "move-column-to-workspace down";
          }
          {
            key = "cmd+alt+ctrl-u";
            niri = "move-column-to-workspace-down;";
            omni = omni "move-column-to-workspace down";
          }
          {
            key = "cmd+alt+ctrl-up";
            niri = "move-column-to-workspace-up;";
            omni = omni "move-column-to-workspace up";
          }
          {
            key = "cmd+alt+ctrl-i";
            niri = "move-column-to-workspace-up;";
            omni = omni "move-column-to-workspace up";
          }

          # Move Workspaces (niri only)
          {
            key = "cmd+alt+shift-pagedown";
            niri = "move-workspace-down;";
          }
          {
            key = "cmd+alt+shift-pageup";
            niri = "move-workspace-up;";
          }
          {
            key = "cmd+alt+shift-u";
            niri = "move-workspace-down;";
          }
          {
            key = "cmd+alt+shift-i";
            niri = "move-workspace-up;";
          }

          # Monitor Navigation
          {
            key = "cmd+alt+ctrl-h";
            niri = "focus-monitor-left;";
            omni = omni "focus-monitor prev";
          }
          {
            key = "cmd+alt+ctrl-j";
            niri = "focus-monitor-down;";
          }
          {
            key = "cmd+alt+ctrl-k";
            niri = "focus-monitor-up;";
          }
          {
            key = "cmd+alt+ctrl-l";
            niri = "focus-monitor-right;";
            omni = omni "focus-monitor next";
          }
          {
            key = "cmd+alt+ctrl-left";
            niri = "focus-monitor-left;";
            omni = omni "focus-monitor prev";
          }
          {
            key = "cmd+alt+ctrl-right";
            niri = "focus-monitor-right;";
            omni = omni "focus-monitor next";
          }

          # Move to Monitor
          {
            key = "cmd+alt+shift+ctrl-h";
            niri = "move-column-to-monitor-left;";
            omni = omni "swap-workspace-with-monitor left";
          }
          {
            key = "cmd+alt+shift+ctrl-j";
            niri = "move-column-to-monitor-down;";
          }
          {
            key = "cmd+alt+shift+ctrl-k";
            niri = "move-column-to-monitor-up;";
          }
          {
            key = "cmd+alt+shift+ctrl-l";
            niri = "move-column-to-monitor-right;";
            omni = omni "swap-workspace-with-monitor right";
          }
          {
            key = "cmd+alt+shift+ctrl-left";
            niri = "move-workspace-to-monitor-left;";
            omni = omni "swap-workspace-with-monitor left";
          }
          {
            key = "cmd+alt+shift+ctrl-right";
            niri = "move-workspace-to-monitor-right;";
            omni = omni "swap-workspace-with-monitor right";
          }

          # Mouse Wheel Navigation
          {
            key = "cmd+alt-wheelscrolldown";
            niri = "focus-workspace-down;";
            niriArgs = "cooldown-ms=150";
          }
          {
            key = "cmd+alt-wheelscrollup";
            niri = "focus-workspace-up;";
            niriArgs = "cooldown-ms=150";
          }
          {
            key = "cmd+alt+ctrl-wheelscrolldown";
            niri = "move-column-to-workspace-down;";
            niriArgs = "cooldown-ms=150";
          }
          {
            key = "cmd+alt+ctrl-wheelscrollup";
            niri = "move-column-to-workspace-up;";
            niriArgs = "cooldown-ms=150";
          }
          {
            key = "cmd+alt-wheelscrollright";
            niri = "focus-column-right;";
          }
          {
            key = "cmd+alt-wheelscrollleft";
            niri = "focus-column-left;";
          }
          {
            key = "cmd+alt+ctrl-wheelscrollright";
            niri = "move-column-right;";
          }
          {
            key = "cmd+alt+ctrl-wheelscrollleft";
            niri = "move-column-left;";
          }
          {
            key = "cmd+alt+shift-wheelscrolldown";
            niri = "focus-column-right;";
          }
          {
            key = "cmd+alt+shift-wheelscrollup";
            niri = "focus-column-left;";
          }
          {
            key = "cmd+alt+ctrl+shift-wheelscrolldown";
            niri = "move-column-right;";
          }
          {
            key = "cmd+alt+ctrl+shift-wheelscrollup";
            niri = "move-column-left;";
          }

          # Screenshots
          {
            key = "xf86launch1";
            niri = "screenshot;";
            omni = run "screencapture -i";
          }
          {
            key = "ctrl-xf86launch1";
            niri = "screenshot-screen;";
            omni = run "screencapture -c";
          }
          {
            key = "alt-xf86launch1";
            niri = "screenshot-window;";
            omni = run "screencapture -cw";
          }
          {
            key = "print";
            niri = "screenshot;";
            omni = run "screencapture -i";
          }
          {
            key = "ctrl-print";
            niri = "screenshot-screen;";
            omni = run "screencapture -c";
          }
          {
            key = "alt-print";
            niri = "screenshot-window;";
            omni = run "screencapture -cw";
          }

          # Audio and Media
          {
            key = "fn-f10";
            omni = osascript "set volume output muted not (output muted of (get volume settings))";
          }
          {
            key = "fn-f11";
            omni = osascript "set volume output volume (output volume of (get volume settings) - 5)";
          }
          {
            key = "fn-f12";
            omni = osascript "set volume output volume (output volume of (get volume settings) + 5)";
          }

          {
            key = "xf86audioraisevolume";
            niri = ''spawn "dms" "ipc" "call" "audio" "increment" "3";'';
            niriArgs = "allow-when-locked=true";
          }
          {
            key = "xf86audiolowervolume";
            niri = ''spawn "dms" "ipc" "call" "audio" "decrement" "3";'';
            niriArgs = "allow-when-locked=true";
          }
          {
            key = "xf86audiomute";
            niri = ''spawn "dms" "ipc" "call" "audio" "mute";'';
            niriArgs = "allow-when-locked=true";
          }
          {
            key = "xf86audiomicmute";
            niri = ''spawn "dms" "ipc" "call" "audio" "micmute";'';
            niriArgs = "allow-when-locked=true";
          }
          {
            key = "xf86audioplay";
            niri = ''spawn "dms" "ipc" "call" "mpris" "playPause";'';
            niriArgs = "allow-when-locked=true";
          }
          {
            key = "xf86audiostop";
            niri = ''spawn "dms" "ipc" "call" "mpris" "stop";'';
            niriArgs = "allow-when-locked=true";
          }
          {
            key = "xf86audionext";
            niri = ''spawn "dms" "ipc" "call" "mpris" "next";'';
            niriArgs = "allow-when-locked=true";
          }
          {
            key = "xf86audioprev";
            niri = ''spawn "dms" "ipc" "call" "mpris" "previous";'';
            niriArgs = "allow-when-locked=true";
          }
          {
            key = "xf86monbrightnessup";
            niri = ''spawn "dms" "ipc" "call" "brightness" "increment" "5" "";'';
            niriArgs = "allow-when-locked=true";
          }
          {
            key = "xf86monbrightnessdown";
            niri = ''spawn "dms" "ipc" "call" "brightness" "decrement" "5" "";'';
            niriArgs = "allow-when-locked=true";
          }
          {
            key = "cmd+alt-escape";
            niri = "toggle-keyboard-shortcuts-inhibit;";
            niriArgs = "allow-inhibiting=false";
          }
        ]
        ++ genWorkspaceBinds;
    };
  };
}
