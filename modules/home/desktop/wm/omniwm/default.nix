{
  config,
  lib,
  pkgs,
  ...
}: let
  settingsFormat = pkgs.formats.toml {};

  omniwmLib = import ./lib.nix {inherit lib;};

  stylixColor = name: omniwmLib.colorFromHex "#${config.lib.stylix.colors.${name}}";
  appRules = import ./app-rules.nix {inherit omniwmLib;};
  workspaces = import ./workspaces.nix {inherit omniwmLib;};

  settings = {
    monitorBarOverrides = [];
    monitorDwindleOverrides = [];
    monitorNiriOverrides = [];
    monitorOrientationOverrides = [];

    appearance.mode = "dark";

    borders = {
      enabled = false;
      width = 2.0;
      color = stylixColor "base0D";
    };

    dwindle = {
      defaultSplitRatio = 1.0;
      moveToRootStable = true;
      singleWindowAspectRatio = "4:3";
      smartSplit = false;
      splitWidthMultiplier = 1.0;
      useGlobalGaps = true;
    };

    clipboard = {
      historyEnabled = false;
      maxItemBytes = 8388608;
      maxItems = 200;
      maxTotalBytes = 67108864;
    };

    focus = {
      followsMouse = true;
      followsWindowToMonitor = true;
      moveMouseToFocusedWindow = false; # interacts badly with `followsMouse` making it center each time
    };

    gaps = {
      size = 4.0;
      outer = {
        bottom = 0.0;
        left = 0.0;
        right = 0.0;
        top = 0.0;
      };
    };

    general = {
      animationsEnabled = true;
      defaultLayoutType = "niri";
      hotkeysEnabled = false;
      hyperKeyHoldThresholdMilliseconds = 150;
      hyperTrigger = "Left Option";
      ipcEnabled = true;
      preventSleepEnabled = false;
      updateChecksEnabled = true;
    };

    gestures = {
      fingerCount = 3;
      invertDirection = true;
      mouseResizeModifierKey = "option";
      scrollEnabled = true;
      scrollModifierKey = "optionShift";
      scrollSensitivity = 5.0;
    };

    mouseWarp = {
      axis = "horizontal";
      margin = 1;
      monitorOrder = [];
    };

    niri = {
      alwaysCenterSingleColumn = false;
      centerFocusedColumn = "never";
      columnWidthPresets = [
        0.3333333333333333
        0.5
        0.6666666666666666
      ];
      defaultColumnWidth = 0.5;
      infiniteLoop = false;
      maxVisibleColumns = 2;
      singleWindowAspectRatio = "none";
    };

    quakeTerminal = {
      animationDuration = 0.2;
      autoHide = false;
      enabled = true;
      heightPercent = 50.0;
      monitorMode = "focusedWindow";
      opacity = 1.0;
      position = "center";
      widthPercent = 50.0;
    };

    statusBar = {
      showAppNames = false;
      showWorkspaceName = false;
      useWorkspaceId = false;
    };

    workspaceBar = {
      backgroundOpacity = 0.1;
      deduplicateAppIcons = false;
      enabled = false;
      height = 24.0;
      hideEmptyWorkspaces = false;
      labelFontSize = 12.0;
      notchAware = true;
      position = "overlappingMenuBar";
      reserveLayoutSpace = false;
      showFloatingWindows = false;
      showLabels = true;
      windowLevel = "popup";
      xOffset = 0.0;
      yOffset = 0.0;
      accentColor = stylixColor "base0D";
      textColor = stylixColor "base05";
    };

    inherit appRules;
    inherit workspaces;
  };
in {
  xdg.configFile."omniwm/settings.toml" = lib.mkIf pkgs.stdenv.isDarwin {
    source = settingsFormat.generate "omniwm-settings.toml" settings;
  };
}
