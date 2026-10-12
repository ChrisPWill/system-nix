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
    inputs.mac-app-util.darwinModules.default
    inputs.stylix.darwinModules.stylix
    inputs.self.modules.theming.theme
    ./desktop.nix
    ./skhd.nix
  ];
  nixpkgs.overlays = [
    # TODO: delete once cache.nixos.org serves an aarch64-darwin codex-acp
    # (https://hydra.nixos.org/job/nixpkgs/unstable/codex-acp.aarch64-darwin).
    # Its test suite spawns Codex, which fails to read macOS managed
    # preferences as the sandboxed nixbld user, so Hydra never caches it and
    # local builds fail the same way.
    (final: prev: {
      codex-acp =
        lib.warn
        "codex-acp ${prev.codex-acp.version}: tests disabled by an overlay in modules/darwin/darwin-shared.nix; remove it once Hydra builds codex-acp.aarch64-darwin"
        (prev.codex-acp.overrideAttrs {doCheck = false;});
    })
    # TODO: delete once nixos-unstable moves past the debugpy 1.8.22 build that
    # failed on Hydra (https://hydra.nixos.org/build/348649076); nixpkgs-unstable
    # already has a passing, cached build. Until then it builds locally, where
    # test_lldb_command fails.
    (final: prev: {
      pythonPackagesExtensions =
        prev.pythonPackagesExtensions
        ++ [
          (pyFinal: pyPrev: {
            debugpy =
              lib.warn
              "debugpy ${pyPrev.debugpy.version}: test_lldb_command disabled by an overlay in modules/darwin/darwin-shared.nix; remove it once nixos-unstable has a cached debugpy"
              (pyPrev.debugpy.overridePythonAttrs (old: {
                disabledTests = (old.disabledTests or []) ++ ["test_lldb_command"];
              }));
          })
        ];
    })
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
