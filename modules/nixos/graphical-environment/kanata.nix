{...}: {
  services.kanata = {
    enable = true;
    keyboards = {
      default = {
        extraArgs = ["--nodelay"];
        config = ''
          (defsrc
            caps t g m j d s
          )

          (defalias
            cap (tap-hold 100 100 esc (layer-toggle leader))
          )

          (deflayer base
            @cap t g m j d s
          )

          (deflayer leader
            _ M-A-S-t M-A-S-g (layer-toggle monitor) _ M-A-S-d M-A-S-s
          )

          (deflayer monitor
            _ M-A-S-b _ _ M-A-S-j _ _
          )
        '';
      };
    };
  };
}
