{...}: {
  services.kanata = {
    enable = true;
    keyboards = {
      default = {
        extraArgs = ["--nodelay"];
        config = ''
          (defsrc
            caps t
          )

          (defalias
            cap (tap-hold 200 200 esc (layer-toggle leader))
          )

          (deflayer base
            @cap t
          )

          (deflayer leader
            _ M-A-S-t
          )
        '';
      };
    };
  };
}
