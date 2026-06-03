{lib, ...}: {
  options.kanata.globalLeader = {
    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["--nodelay" "--no-wait"];
      description = "Extra command-line arguments for the Kanata global leader service.";
    };

    defcfg = lib.mkOption {
      type = lib.types.lines;
      default = ''
        process-unmapped-keys yes
      '';
      description = "The content of the defcfg block for Kanata.";
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
        )

        (defsrc
          caps
        )

        (deflayer base
          @lead
        )
      '';
      description = "Kanata configuration for the cross-platform global leader key (excluding defcfg).";
    };
  };
}
