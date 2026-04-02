{
  lib,
  pkgs,
  config,
  ...
}: {
  options = with lib; {
    programs.nushell.enableDefaultInteractive = mkEnableOption "make default interactive shell";
  };
  config = {
    programs.zsh.initContent = lib.mkIf config.programs.nushell.enableDefaultInteractive (lib.mkOrder 500 ''
      # Launch Nushell if we are interactive and haven't already launched it
      if [[ $- == *i* && -z "$NU_LAUNCHED" ]]; then
        export NU_LAUNCHED=true
        exec nu
      fi
    '');
    programs.nushell = {
      enable = true;

      settings = {
        show_banner = false;
        edit_mode = "vi";
      };

      plugins = with pkgs.nushellPlugins; [
        formats
      ];

      environmentVariables = {
        # Nushell doesn't get some of the Nix binary paths by default
        PATH = lib.hm.nushell.mkNushellInline (''
            ($env.PATH |
              split row (char esep) |
              append $"($env.HOME)/.nix-profile/bin" |
              append $"/etc/profiles/per-user/($env.USER)/bin" |
              append "/run/current-system/sw/bin" |
              append "/nix/var/nix/profiles/default/bin"
          ''
          + lib.optionalString pkgs.stdenv.isDarwin ''
            |
            append "/opt/homebrew/bin"
          ''
          + lib.optionalString config.isAtlassianMachine ''
            |
            append "/opt/atlassian/bin"
          ''
          + ")");
      };
      extraConfig = ''
        # Shows system information on startup
        ${pkgs.fastfetch}/bin/fastfetch -s title:separator:os:cpu:memory:host:chassis:kernel:de:wm:wmtheme:swap:disk:battery:poweradapter:uptime:separator:shell:font:terminal:terminalfont:break:colors

        # Bind custom keybinding for television file picker
        $env.config = (
          $env.config
          | upsert keybindings (
              $env.config.keybindings
              | append [
                  {
                      name: tv_nvim,
                      modifier: Alt,
                      keycode: char_o,
                      mode: [vi_normal, vi_insert, emacs],
                      event: {
                          send: executehostcommand,
                          cmd: "tv-nvim"
                      }
                  },
                  {
                      name: viddy_command,
                      modifier: Alt,
                      keycode: char_w,
                      mode: [vi_normal, vi_insert, emacs],
                      event: {
                          send: executehostcommand,
                          cmd: "let cmd = (commandline); if ($cmd | str length) > 0 { viddy -n 1 -- $cmd }"
                      }
                  }
              ]
          )
        )
      '';

      shellAliases.fg = "job unfreeze";
    };
  };
}
