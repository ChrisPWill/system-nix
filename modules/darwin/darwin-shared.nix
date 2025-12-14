{inputs, ...}: {
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
    inputs.stylix.darwinModules.stylix
    inputs.self.modules.theming.theme
  ];
  nix.settings.experimental-features = ["nix-command" "flakes"];

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
      # Tap for AeroSpace window manager
      "nikitabobko/tap"
    ];

    casks = [
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

  stylix.enable = true;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/onedark.yaml";

  services.jankyborders = let
    theme = config.theme;
  in {
    enable = true;
    active_color = theme.background;
    inactive_color = theme.background-defocused;
    width = 7.0;
  };

  system = {
    keyboard.enableKeyMapping = true;
    keyboard.remapCapsLockToEscape = true;

    defaults = {
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
