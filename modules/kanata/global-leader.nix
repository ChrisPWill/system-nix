{
  config,
  lib,
  ...
}: let
  cfg = config.kanata.globalLeader;
  macOSFunctionRow = cfg.functionRowMode == "macos-media";
in {
  options.kanata.globalLeader = {
    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["--nodelay" "--no-wait"];
      description = "Extra command-line arguments for the Kanata global leader service.";
    };

    defcfg = lib.mkOption {
      type = lib.types.lines;
      default = ''
        ;; Only process keys listed in defsrc. On macOS, processing every
        ;; unmapped key causes the top-row keys to bypass native Fn/media handling.
        process-unmapped-keys no
      '';
      description = "The content of the defcfg block for Kanata.";
    };

    functionRowMode = lib.mkOption {
      type = lib.types.enum [
        "unmanaged"
        "macos-media"
      ];
      default = "unmanaged";
      description = ''
        How Kanata handles the function row. The macos-media mode maps the
        supported Apple media keys explicitly and exposes F1-F12 while Fn is
        held.
      '';
    };

    config = lib.mkOption {
      type = lib.types.lines;
      default = ''
        (defalias
          ;; Modifiers
          m (multi lmet lalt)
          ms (multi lmet lalt lsft)

          ;; Tap: Esc, Hold: Cmd+Alt, Double-Tap Hold: Cmd+Alt+Shift
          lead (tap-dance 80 (
            (tap-hold 80 80 esc @m)
            (tap-hold 80 80 esc @ms)
          ))
          ${lib.optionalString macOSFunctionRow ''
          ;; macOS presents the top row to Kanata as F1-F12. Re-emit the
          ;; supported consumer keys explicitly; hold Fn for real F-keys.
          fn-row (tap-hold 200 200 fn (layer-toggle function-keys))
        ''}
        )

        (defsrc
          caps
          ${lib.optionalString macOSFunctionRow ''
          f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11 f12
          fn up down
        ''}
        )

        (deflayer base
          @lead
          ${lib.optionalString macOSFunctionRow ''
          brdn brup f3 f4 f5 f6 prev pp next mute vold volu
          @fn-row up down
        ''}
        )

        ${lib.optionalString macOSFunctionRow ''
          (deflayer function-keys
            _
            f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11 f12
            _ pgup pgdn
          )
        ''}
      '';
      description = "Kanata configuration for the cross-platform global leader key (excluding defcfg).";
    };
  };
}
