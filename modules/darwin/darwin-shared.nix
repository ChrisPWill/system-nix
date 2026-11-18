{inputs, ...}: {
  config,
  lib,
  ...
}: {
  imports = [
    inputs.self.modules.shared.approved-apps
    inputs.nix-homebrew.darwinModules.nix-homebrew
    inputs.mac-app-util.darwinModules.default
    inputs.stylix.darwinModules.stylix
    inputs.self.modules.theming.theme
    ./desktop.nix
    ./keychain-ca-bundle.nix
    ./skhd.nix
  ];
  nixpkgs.overlays = [
    # TODO: delete once nixpkgs disables zathura's tests-x11/tests-wayland
    # features on Darwin. nixpkgs forces meson auto features on, so configure
    # demands xvfb-run, which is Linux-only, even though doCheck is off there.
    (_final: prev: {
      zathuraPkgs = prev.zathuraPkgs.overrideScope (_zFinal: zPrev: {
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
  # Running `brew shellenv` in every new shell costs ~1.3s of a 1.65s zsh start
  # on this laptop, because each fresh exec (bash, brew, brew.sh) is slow under
  # the endpoint-security agents. Its output is constant for this prefix, so the
  # shells below set the same environment statically instead. Keep these in sync
  # with `brew shellenv` if the Homebrew prefix ever changes.
  programs.zsh = {
    enableCompletion = false;
    promptInit = "";
    interactiveShellInit = ''
      export HOMEBREW_PREFIX="/opt/homebrew"
      export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
      export HOMEBREW_REPOSITORY="/opt/homebrew/Library/.homebrew-is-managed-by-nix"
      fpath[1,0]="/opt/homebrew/share/zsh/site-functions"
      export FPATH
      export PATH="/opt/homebrew/bin:/opt/homebrew/sbin''${PATH+:$PATH}"
      export INFOPATH="/opt/homebrew/share/info:''${INFOPATH:-}"
    '';
  };

  programs.fish = {
    # The foreign-env bridge currently costs multiple seconds on each fish start
    # even for empty shell snippets. Babelfish keeps the Darwin environment setup
    # in native fish syntax.
    useBabelfish = true;
    interactiveShellInit = lib.mkForce ''
      set --global --export HOMEBREW_PREFIX "/opt/homebrew"
      set --global --export HOMEBREW_CELLAR "/opt/homebrew/Cellar"
      set --global --export HOMEBREW_REPOSITORY "/opt/homebrew/Library/.homebrew-is-managed-by-nix"
      fish_add_path --global --move --path "/opt/homebrew/bin" "/opt/homebrew/sbin"
      if not set --query INFOPATH; set INFOPATH ""; end
      set --global --export INFOPATH "/opt/homebrew/share/info" $INFOPATH
    '';
  };

  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    autoMigrate = true;
    user = config.system.primaryUser;
    # Replaced by the static environment in programs.zsh/fish above.
    enableZshIntegration = false;
    enableFishIntegration = false;
  };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = lib.mkDefault "uninstall";
    };

    taps = lib.optionals config.appApproved.omniwm [
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

  # Borders only help to see which window OmniWM has focused.
  services.jankyborders = {
    enable = config.appApproved.omniwm;
    width = 7.0;
    blacklist = ["Loom"];
  };

  launchd.user.agents.set-gui-path = {
    # Home Manager installs into /etc/profiles/per-user when nix-darwin runs
    # it, and into the user's own profile when it runs standalone.
    script = let
      userBin =
        if config.home-manager.users ? ${config.system.primaryUser}
        then "/etc/profiles/per-user/$USER/bin"
        else "$HOME/.nix-profile/bin";
    in ''
      /bin/launchctl setenv PATH "/run/current-system/sw/bin:${userBin}:$PATH"
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
