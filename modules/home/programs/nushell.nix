{
  lib,
  pkgs,
  ...
}: {
  programs.nushell = {
    enable = true;

    settings = {
      show_banner = false;
      edit_mode = "vi";
    };
    environmentVariables = {
      # Nushell doesn't get some of the Nix binary paths by default
      PATH = lib.hm.nushell.mkNushellInline ''
        ($env.PATH |
          split row (char esep) |
          append $"($env.HOME)/.nix-profile/bin" |
          append $"/etc/profiles/per-user/($env.USER)/bin" |
          append "/run/current-system/sw/bin" |
          append "/nix/var/nix/profiles/default/bin"
        )
      '';
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
                cmd: "commandline edit --insert (fzf --layout=reverse --height=40% -q (commandline) | decode utf-8 | str trim)"
              }
            ]
          }
      ))

      # Shows system information on startup
      ${pkgs.fastfetch}/bin/fastfetch -s title:separator:os:cpu:memory:host:chassis:kernel:de:wm:wmtheme:swap:disk:battery:poweradapter:uptime:separator:shell:font:terminal:terminalfont:colors
    '';

    shellAliases.fg = "job unfreeze";
  };
}
