{inputs, ...}: {lib, ...}: {
  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
    inputs.mac-app-util.darwinModules.default
    inputs.stylix.darwinModules.stylix
    inputs.self.modules.theming.theme
    ./desktop.nix
    ./skhd.nix
  ];
  nixpkgs.overlays = [
    # TODO: delete once nixpkgs disables zathura's tests-x11/tests-wayland
    # features on Darwin. nixpkgs forces meson auto features on, so configure
    # demands xvfb-run, which is Linux-only, even though doCheck is off there.
    (final: prev: {
      zathuraPkgs = prev.zathuraPkgs.overrideScope (zFinal: zPrev: {
        zathura_core =
          lib.warn
          "zathura ${zPrev.zathura_core.version}: X11/Wayland test features disabled by an overlay in modules/darwin/darwin-shared.nix; remove it once nixpkgs builds zathura on Darwin"
          (zPrev.zathura_core.overrideAttrs (old: {
            mesonFlags =
              old.mesonFlags
              ++ [
                (lib.mesonEnable "tests-x11" false)
                (lib.mesonEnable "tests-wayland" false)
              ];
          }));
      });
    })
  ];

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
