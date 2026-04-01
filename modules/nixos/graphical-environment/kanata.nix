{...}: {
  services.kanata = {
    enable = true;
    keyboards = {
      default = {
        extraArgs = ["--nodelay"];
        config = ''
          (defsrc
            caps t g m j
          )

          (defalias
            cap (tap-hold 100 100 esc (layer-toggle leader))
          )

          (deflayer base
            @cap t g m j
          )

          (deflayer leader
            _ M-A-S-t M-A-S-g (layer-toggle monitor) _
          )

          (deflayer monitor
            _ M-A-S-b _ _ M-A-S-j
          )
        '';
      };
    };
  };
}
