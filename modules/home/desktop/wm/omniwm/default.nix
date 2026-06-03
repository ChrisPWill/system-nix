{
  config,
  lib,
  pkgs,
  ...
}: let
  settingsFormat = pkgs.formats.toml {};

  colorFromHex = color: let
    hex = lib.removePrefix "#" color;
    channel = offset: (lib.fromHexString (builtins.substring offset 2 hex)) / 255.0;
  in {
    red = channel 0;
    green = channel 2;
    blue = channel 4;
    alpha = 1.0;
  };

  stylixColor = name: colorFromHex "#${config.lib.stylix.colors.${name}}";

  appRule = id: bundleId: attrs:
    {
      inherit id bundleId;
    }
    // attrs;

  workspace = id: name: monitorAssignment: attrs:
    {
      inherit id name;
      layoutType = "niri";
      monitorAssignment.type = monitorAssignment;
    }
    // attrs;

  # Keep OmniWM's useful built-in sizing defaults, then layer local float rules
  # for popups and transient utility windows.
  appRules = [
    (appRule "6A31F08A-4051-4354-B439-42F4C71894A3" "com.openai.codex" {
      minHeight = 600.0;
      minWidth = 800.0;
    })
    (appRule "4BA546DA-2875-4BEF-B13F-1539E833B1A0" "com.eltima.cmd1.pro.mas" {
      minHeight = 550.0;
      minWidth = 950.0;
    })
    (appRule "486CEFA6-69AA-4A3C-AF27-BCD38F4F138B" "com.google.Chrome" {
      minHeight = 375.0;
      minWidth = 500.0;
    })
    (appRule "979F05F4-FFA2-4EDD-B23F-08A9944C759F" "dev.zed.Zed" {
      minHeight = 240.0;
      minWidth = 360.0;
    })
    (appRule "81426D13-C1A5-475E-AFBC-00BBA05042D0" "com.apple.Safari" {
      minHeight = 220.0;
      minWidth = 574.0;
    })
    (appRule "1CF39647-F30D-4E76-9686-79B551F1B094" "app.zen-browser.zen" {
      minHeight = 495.0;
      minWidth = 500.0;
    })
    (appRule "005C00D3-F665-47F8-BDAE-D80790E9E46B" "org.mozilla.firefox" {
      minHeight = 120.0;
      minWidth = 500.0;
    })
    (appRule "C21156B1-0224-4998-97E3-8F4FA65B9F3B" "company.thebrowser.dia" {
      minHeight = 420.0;
      minWidth = 500.0;
    })
    (appRule "2DE9390B-0DB4-4D0C-9ABA-06F76F1D4EA9" "com.spotify.client" {
      minHeight = 600.0;
      minWidth = 800.0;
    })
    (appRule "AF752D95-8497-4844-BE20-4C93E73BAEF2" "com.hnc.Discord" {
      minHeight = 500.0;
      minWidth = 800.0;
    })
    (appRule "7876C9EF-437E-4D4F-9C27-B1B02F4AABCE" "com.mitchellh.ghostty" {
      minHeight = 48.0;
      minWidth = 90.0;
    })
    (appRule "8ECAB78B-BCDD-4245-BC25-1609A49B1C86" "com.microsoft.Outlook" {
      minHeight = 650.0;
      minWidth = 930.0;
    })
    (appRule "552FB77D-BF0E-4737-90A6-B5BC6986C579" "com.apple.MobileSMS" {
      minHeight = 320.0;
      minWidth = 660.0;
    })
    (appRule "1C64F561-8A2C-43B4-8D7D-3E11D5C7F931" "com.apple.systempreferences" {
      layout = "float";
      minHeight = 650.0;
      minWidth = 900.0;
    })
    (appRule "0CF3018F-7306-4095-9A02-FB5A98F869F7" "com.apple.finder" {
      layout = "float";
      titleSubstring = "Preferences";
    })
    (appRule "A58E2186-F260-4EB5-86A1-B83F4251D25B" "com.apple.calculator" {
      layout = "float";
      minHeight = 420.0;
      minWidth = 320.0;
    })
    (appRule "F2C9B841-8B84-4F8D-9828-42DAB5E41443" "com.apple.ActivityMonitor" {
      layout = "float";
      minHeight = 520.0;
      minWidth = 700.0;
    })
    (appRule "7E60F6F8-4357-4C90-9F49-56A6585EA291" "com.raycast.macos" {
      layout = "float";
      minHeight = 420.0;
      minWidth = 600.0;
    })
    (appRule "2E4D3910-895A-49D8-8E7F-74782A55058B" "com.mitchellh.ghostty" {
      layout = "float";
      minHeight = 600.0;
      minWidth = 900.0;
      titleSubstring = "ghostty-floating";
    })
    (appRule "F1663566-B510-4D23-A79E-D2D9FAD6F071" "com.mitchellh.ghostty" {
      layout = "float";
      minHeight = 240.0;
      minWidth = 700.0;
      titleSubstring = "quick-capture";
    })
    (appRule "180E94E1-4EE3-4B90-84D0-7CB21A43C730" "md.obsidian" {
      minHeight = 600.0;
      minWidth = 800.0;
    })
    (appRule "D383F065-A332-428C-9E11-20915C21F6D2" "com.electron.logseq" {
      minHeight = 600.0;
      minWidth = 800.0;
    })
  ];

  workspaceConfigurations = [
    (workspace "AD36F001-C57E-41A5-AC1D-DF5249D007F0" "1" "main" {})
    (workspace "454CECD4-5E9D-4ED1-95D7-979D48817F5F" "2" "main" {})
    (workspace "BEB842B5-E894-4791-9FD1-397C3CDD3538" "3" "main" {})
    (workspace "248AA883-2261-4D45-943C-79C0E46A232B" "4" "main" {})
    (workspace "8B8C45D6-CE9E-41D9-BD50-BE4989D5E3DE" "5" "main" {})
    (workspace "5953F2BF-A378-4266-91B2-287174C4FA4D" "6" "main" {})
    (workspace "A7D5E104-6985-4516-8ED5-07F144F2A33D" "7" "main" {})
    (workspace "0978B19D-5380-492B-B7F3-6A325B390F71" "8" "main" {})
    (workspace "7E95FE7A-D633-4D41-95E0-3D28A466E66E" "9" "main" {})

    # OmniWM raw workspace names are numeric and monitor assignments are
    # semantic. Display names preserve the laptop workspace labels used by the
    # skhd bindings.
    (workspace "E03D84B1-2E74-44FC-96C1-57C6DA132911" "10" "secondary" {
      displayName = "Q";
    })
    (workspace "B6F19E3D-9B42-427D-9C1E-F0E3E6D6C0E3" "11" "secondary" {
      displayName = "W";
    })
    (workspace "D89AF713-3C9A-4D3E-A980-7C8BAEC3F816" "12" "secondary" {
      displayName = "E";
    })
    (workspace "8F1B3D9E-1B13-4F86-BC37-87C7A443E541" "13" "secondary" {
      displayName = "A";
    })
    (workspace "37F8D135-6C7F-42CA-97DD-4759270C4CB3" "14" "secondary" {
      displayName = "S";
    })
    (workspace "5F1B6A6D-C399-43F4-806E-036475FC8DC2" "15" "secondary" {
      displayName = "D";
    })
  ];

  settings = {
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

    focus = {
      followsMouse = false;
      followsWindowToMonitor = true;
      moveMouseToFocusedWindow = true;
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
      hyperTrigger = "Option";
      ipcEnabled = true;
      leaderKey = "Hyper+Space";
      preventSleepEnabled = false;
      sequenceTimeoutMilliseconds = 800;
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
    workspaces = workspaceConfigurations;
  };
in {
  xdg.configFile."omniwm/settings.toml" = lib.mkIf pkgs.stdenv.isDarwin {
    source = settingsFormat.generate "omniwm-settings.toml" settings;
  };
}
