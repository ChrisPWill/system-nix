{
  lib,
  pkgs,
  config,
  ...
}: let
  approved = config.appApproved;
in {
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
      enable = approved.fish;
      # zsh execs fish when this is on, so it must never outlive fish itself.
      enableDefaultInteractive = approved.fish;

      interactiveShellInit =
        ''
          # Enables vi(m)-like key bindings (insert mode by default)
          fish_vi_key_bindings

          # Complete `detach` as if its arguments were a command line of their own
          complete -c detach -xa '(__fish_complete_subcommand)'
        ''
        + lib.optionalString approved.fastfetch ''

          ${pkgs.fastfetch}/bin/fastfetch -s title:separator:os:cpu:memory:host:chassis:kernel:de:wm:wmtheme:swap:disk:battery:poweradapter:uptime:separator:shell:font:terminal:terminalfont:break:colors
        '';

      functions = {
        detach = {
          description = "Launch any application detached in the background";
          body = ''
            if test (count $argv) -eq 0
                echo "Usage: detach <command> [arguments]" >&2
                return 1
            end

            # $argv as a command resolves functions and builtins too, not just
            # binaries, so this stays a general-purpose launcher.
            $argv &>/dev/null &
            disown
          '';
        };
      };

      plugins = let
        fishP = name: {
          inherit name;
          inherit (pkgs.fishPlugins.${name}) src;
        };
      in
        lib.optionals approved.forgit [
          # interactive selectors for git
          # See https://github.com/wfxr/forgit for list
          (fishP "forgit")
        ];
    };

    home.packages = config.filterApproved {
      inherit (pkgs) fzf; # used by the forgit plugin
    };
  };
}
