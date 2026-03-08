{
  lib,
  pkgs,
  config,
  ...
}: {
  options = with lib; {
    programs.fish.enableDefaultInteractive = mkEnableOption "make default interactive shell";
  };
  config = {
    programs.zsh.initContent = lib.mkIf config.programs.fish.enableDefaultInteractive (lib.mkOrder 500 ''
      # Launch Fish if we are interactive and haven't already launched it
      if [[ $- == *i* && -z "$FISHY_FREE" ]]; then
        export FISHY_FREE=true
        exec fish
      fi
    '');
    programs.fish = {
      enable = true;
      enableDefaultInteractive = true;

      interactiveShellInit = ''
        # Enables vi(m)-like key bindings (insert mode by default)
        fish_vi_key_bindings

        ${pkgs.fastfetch}/bin/fastfetch -s title:separator:os:cpu:memory:host:chassis:kernel:de:wm:wmtheme:swap:disk:battery:poweradapter:uptime:separator:shell:font:terminal:terminalfont:break:colors
      '';

      shellAbbrs = {
        unzip = "ouch";
      };
    };
  };
}
