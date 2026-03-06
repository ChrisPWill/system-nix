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
        # fzf support
        $env.config = ($env.config | upsert keybindings (
          $env.config.keybindings
          | append {
              name: fzf_file_search
              modifier: control
              keycode: char_t
              mode: [vi_normal, vi_insert]
              event: [
                {
                  send: executehostcommand
                  cmd: "commandline edit --insert (fzf --layout=reverse --height=40% | decode utf-8 | str trim)"
                }
              ]
            }
        ))

        # Shows system information on startup
        ${pkgs.fastfetch}/bin/fastfetch -s title:separator:os:cpu:memory:host:chassis:kernel:de:wm:wmtheme:swap:disk:battery:poweradapter:uptime:separator:shell:font:terminal:terminalfont:break:colors
      '';

      shellAliases.fg = "job unfreeze";
    };
  };
}
