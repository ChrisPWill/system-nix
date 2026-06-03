{inputs, ...}: {
  config,
  pkgs,
  ...
}: let
  primaryUser = config.system.primaryUser;
  primaryUserHome = "/Users/${primaryUser}";
in {
  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
    inputs.stylix.darwinModules.stylix
    inputs.self.modules.theming.theme
  ];
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.gc.interval = {
    Hour = 3;
    Minute = 15;
    Weekday = 2;
  };

  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    autoMigrate = true;
    user = "cwilliams";
  };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "uninstall";
    };

    taps = [
      # Tap for OmniWM window manager
      "BarutSRB/tap"

      # Tap for AeroSpace window manager
      "nikitabobko/tap"
    ];

    casks = [
      # Modern macOS window manager
      # github.com/BarutSRB/omni
      "omniwm"

      # Window manager
      # github.com/nikitabobko/AeroSpace
      "aerospace"

      # A graph-based notes app
      "logseq"

      # Useful spotlight alternative
      "raycast"

      # Mandatory, fixes bad scroll behaviour
      "scroll-reverser"
    ];
  };

  services.sketchybar = {
    enable = true;
    extraPackages = [pkgs.jq];
    config = ''
      #!/bin/zsh

      export USER="${primaryUser}"
      export HOME="${primaryUserHome}"
      export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
      export CONFIG_DIR="$HOME/.config/sketchybar"
      export SKETCHYBAR_BIN="${pkgs.sketchybar}/bin/sketchybar"

      if [[ -r "$CONFIG_DIR/sketchybarrc" ]]; then
        source "$CONFIG_DIR/sketchybarrc"
      fi
    '';
  };

  services.jankyborders = {
    enable = true;
    width = 7.0;
    blacklist = ["Loom"];
  };

  system = {
    keyboard.enableKeyMapping = false;
    keyboard.remapCapsLockToEscape = false;

    defaults = {
      CustomUserPreferences = {
        "com.apple.symbolichotkeys" = {
          AppleSymbolicHotKeys = {
            # Disable 'Hide Others' (Cmd+Alt+H) - Conflicts with focus-left
            "30" = {enabled = false;};
            # Disable 'Spotlight' (Cmd+Space) - Conflicts with leader key
            "64" = {enabled = false;};
          };
        };
      };
      screencapture = {
        location = "/tmp";
      };
      dock = {
        autohide = true;
        autohide-delay = 0.2;
        autohide-time-modifier = 2.0;
        mru-spaces = false;
        showhidden = true;
        show-recents = false;
        static-only = true;
      };
      spaces = {
        # OmniWM expects one unified Space spanning all displays.
        spans-displays = true;
      };
      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        QuitMenuItem = true;
        FXEnableExtensionChangeWarning = false;
        ShowPathbar = true;
        ShowStatusBar = true;
        _FXShowPosixPathInTitle = true;
      };
      NSGlobalDomain = {
        AppleKeyboardUIMode = 3;
        ApplePressAndHoldEnabled = false;
        AppleFontSmoothing = 1;
        _HIHideMenuBar = false;
        InitialKeyRepeat = 15;
        KeyRepeat = 1;
        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.swipescrolldirection" = true;
      };

      trackpad = {
        Clicking = true; # tap to click
        TrackpadRightClick = true; # two finger right click
        TrackpadThreeFingerDrag = true;
      };
    };
  };
}
