{inputs, ...}: {
  config,
  lib,
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
    ./desktop.nix
    ./skhd.nix
  ];
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.gc.interval = {
    Hour = 3;
    Minute = 15;
    Weekday = 2;
  };

  # Home Manager owns the interactive zsh prompt and completions. Leaving the
  # nix-darwin defaults on runs compinit before Home Manager runs it again.
  programs.zsh = {
    enableCompletion = false;
    promptInit = "";
  };

  programs.fish = {
    # The foreign-env bridge currently costs multiple seconds on each fish start
    # even for empty shell snippets. Babelfish keeps the Darwin environment setup
    # in native fish syntax.
    useBabelfish = true;
    interactiveShellInit = lib.mkForce ''
      brew shellenv fish 2>/dev/null | source || true
    '';
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
      {
        name = "BarutSRB/tap";
        trusted = true;
      }
    ];
  };

  services.sketchybar = {
    # Disabled in preference to built-in OmniWM bar
    enable = false;
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

  # See https://github.com/nix-darwin/nix-darwin/issues/1817 - maybe can remove shortly
  documentation.enable = false;
  system.tools.darwin-uninstaller.enable = false;

  services.jankyborders = {
    enable = true;
    width = 7.0;
    blacklist = ["Loom"];
  };

  launchd.user.agents.set-gui-path = {
    script = ''
      /bin/launchctl setenv PATH "/run/current-system/sw/bin:/etc/profiles/per-user/$USER/bin:$PATH"
    '';
    serviceConfig = {
      Label = "set-gui-path";
      RunAtLoad = true;
    };
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
            # Disable 'Finder Search' (Cmd+Alt+Space) - Conflicts with leader key
            "65" = {enabled = false;};
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
        # OmniWM expects separate spaces for separate displays.
        spans-displays = false;
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
        # Keep top-row keys for media controls; hold Fn for function keys
        "com.apple.keyboard.fnState" = false;
        _HIHideMenuBar = false;
        InitialKeyRepeat = 15;
        KeyRepeat = 1;
        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.swipescrolldirection" = true;
      };

      trackpad = {
        Clicking = true; # tap to click
        TrackpadRightClick = true; # two finger right click
        TrackpadThreeFingerDrag = false; # frees up 3-finger swipes for OmniWM gestures
      };
    };
  };

  security.pam.services.sudo_local.touchIdAuth = true;
}
