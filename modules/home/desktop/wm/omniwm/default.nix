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
    monitorGapOverrides = [];
    monitorNiriOverrides = [];
    monitorOrientationOverrides = [];
    monitorRoutingOverrides = [];

    appearance.mode = "dark";

    borders = {
      enabled = false;
      width = 2.0;
      color = stylixColor "base0D";
    };

    dwindle = {
      defaultSplitRatio = 1.0;
      moveToRootStable = true;
      singleWindowFit = "1920x1440";
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
      crossesMonitorAtEdge = false;
      followsMouse = false;
      followsWindowToMonitor = true;
      lockModifier = "off";
      moveCrossesMonitorAtEdge = false;
      moveMouseToFocusedWindow = false;
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
      ipcEnabled = true;
      preventSleepEnabled = false;
      systemHyperTrigger = "None";
      updateChecksEnabled = true;
    };

    gestures = {
      fingerCount = 3;
      invertDirection = true;
      mouseResizeModifierKey = "option";
      scrollEnabled = true;
      scrollModifierKey = "optionShift";
      scrollSensitivity = 5.0;
      trackpadScrollStyle = "snap";
      # Vertical 3-finger swipe switches workspaces. Requires macOS's Mission
      # Control 3/4-finger vertical swipe gesture to be disabled (System
      # Settings > Trackpad > More Gestures), otherwise it intercepts the swipe.
      workspaceSwipeEnabled = true;
      workspaceSwipeFingerCount = 3;
      workspaceSwipeAxis = "vertical";
    };

    mouseWarp = {
      constrainToArrangement = false;
      enabled = true;
      margin = 1;
    };

    niri = {
      alwaysCenterSingleColumn = false;
      centerFocusedColumn = "never";
      containerPrimarySpanPresets = [
        0.3333333333333333
        0.5
        0.6666666666666666
      ];
      defaultContainerPrimarySpan = 0.5;
      infiniteLoop = false;
      singleWindowFit = "fill";
      visibleContainerCount = 2;
    };

    overview = {
      zoom = 1.0;
      backdrop = {
        red = 0.05;
        green = 0.05;
        blue = 0.08;
        alpha = 1.0;
      };
      windowBorders = {
        normal = {
          red = 0.3;
          green = 0.3;
          blue = 0.35;
          alpha = 0.5;
        };
        hovered = {
          red = 0.4;
          green = 0.6;
          blue = 1.0;
          alpha = 1.0;
        };
        selected = {
          red = 0.3;
          green = 0.8;
          blue = 0.4;
          alpha = 1.0;
        };
      };
    };

    hiddenBar = {
      enabled = true;
      hiddenBundleIDs = [];
      rehideIntervalSeconds = 5.0;
    };

    quakeTerminal = {
      animationDuration = 0.2;
      autoHide = false;
      enabled = true;
      heightPercent = 50.0;
      # backgroundEffect = "standardBlur";
      # backgroundBlurRadius = 0;
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
      enabled = true;
      excludedBundleIDs = [];
      height = 24.0;
      hideEmptyWorkspaces = false;
      iconOverrides = {};
      notchActiveZoneWidth = 180.0;
      notchMode = "moveBelowMenuBar";
      position = "overlappingMenuBar";
      reserveLayoutSpace = true;
      revealModifier = "off";
      revealHoldMilliseconds = 200.0;
      showFloatingWindows = false;
      showLabels = true;
      systemStatsButton = false;
      windowLevel = "popup";
      xOffset = 0.0;
      yOffset = 0.0;
      accentColor = stylixColor "base0D";
      textColor = stylixColor "base05";
    };

    # Bound via skhd (cmd+alt+shift-slash -> omniwmctl command open-command-palette, see
    # shared-keybinds.nix) instead, since the built-in binding clashes with macOS's
    # "select previous input source" shortcut.
    hotkeys = [
      {
        id = "openCommandPalette";
        binding = "Unassigned";
      }
    ];

    inherit appRules;
    inherit workspaces;
  };

  # OmniWM owns the monitor topology and GUI-maintained collections. Everything
  # else remains policy managed while unknown keys are preserved by the merge.
  policySettings =
    (builtins.removeAttrs settings [
      "monitorBarOverrides"
      "monitorDwindleOverrides"
      "monitorGapOverrides"
      "monitorNiriOverrides"
      "monitorOrientationOverrides"
      "monitorRoutingOverrides"
    ])
    // {
      hiddenBar = builtins.removeAttrs settings.hiddenBar ["hiddenBundleIDs"];
      workspaceBar = builtins.removeAttrs settings.workspaceBar [
        "excludedBundleIDs"
        "iconOverrides"
      ];
    };

  seedFile = settingsFormat.generate "omniwm-settings-seed.toml" settings;
  policyFile = settingsFormat.generate "omniwm-settings-policy.toml" policySettings;
  configPath = "${config.xdg.configHome}/omniwm/settings.toml";
  stateDir = "${config.xdg.stateHome}/system-nix/omniwm";

  mergeSettings = pkgs.writeShellApplication {
    name = "omniwm-config-merge";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.diffutils
      pkgs.jq
      pkgs.remarshal
    ];
    text = ''
      export OMNIWM_CONFIG_PATH=${lib.escapeShellArg configPath}
      export OMNIWM_STATE_DIR=${lib.escapeShellArg stateDir}
      export OMNIWM_SEED_PATH=${lib.escapeShellArg seedFile}
      export OMNIWM_POLICY_PATH=${lib.escapeShellArg policyFile}
      export OMNIWM_MERGE_FILTER=${./merge-settings.jq}

      ${builtins.readFile ./merge-settings.sh}
    '';
  };
in {
  home.packages = lib.optionals pkgs.stdenv.isDarwin [mergeSettings];

  home.activation.mergeOmniwmSettings = lib.mkIf pkgs.stdenv.isDarwin (lib.hm.dag.entryAfter ["writeBoundary"] ''
    run ${lib.getExe mergeSettings}
  '');
}
