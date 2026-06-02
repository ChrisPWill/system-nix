{lib, ...}: {
  options.kanata.globalLeader = {
    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["--nodelay"];
      description = "Extra command-line arguments for the Kanata global leader service.";
    };

    config = lib.mkOption {
      type = lib.types.lines;
      default = ''
        (defcfg
          process-unmapped-keys yes
        )

        (defalias
          ;; Modifiers
          m (multi lmet lalt)
          ms (multi lmet lalt lsft)

          ;; Tap: Esc, Hold: Cmd+Alt, Double-Tap Hold: Cmd+Alt+Shift
          lead (tap-dance 200 (
            (tap-hold 200 200 esc @m)
            (tap-hold 200 200 esc @ms)
          ))
        )

        (defsrc
          caps
        )

        (deflayer base
          @lead
        )
      '';
      description = "Kanata configuration for the cross-platform global leader key.";
    };
  };
}
