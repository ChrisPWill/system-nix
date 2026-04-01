{...}: {
  services.kanata = {
    enable = true;
    keyboards = {
      default = {
        extraArgs = ["--nodelay"];
        config = ''
          (defsrc
            caps t g
          )

          (defalias
            cap (tap-hold 100 100 esc (layer-toggle leader))
          )

          (deflayer base
            @cap t g
          )

          (deflayer leader
            _ M-A-S-t M-A-S-g
          )
        '';
      };
    };
  };
}
