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

        # TV picker for nvim
        for mode in default insert
            bind --mode $mode \eo 'tv-nvim; commandline -f repaint'
        end

        # Viddy current command
        for mode in default insert
            bind --mode $mode \ew 'set -l cmd (commandline); if test -n "$cmd"; commandline -r "viddy -n 1 -- $cmd"; commandline -f execute; end'
        end

        ${pkgs.fastfetch}/bin/fastfetch -s title:separator:os:cpu:memory:host:chassis:kernel:de:wm:wmtheme:swap:disk:battery:poweradapter:uptime:separator:shell:font:terminal:terminalfont:break:colors
      '';

      shellAbbrs = {
        # Nix
        # ---
        nfc = "nix flake check";
        nfu = "nix flake update";
        # Nix shell "interactive"
        nsi = {
          expansion = "nix shell -p % --run fish";
          setCursor = true;
        };

        # Jujutsu
        # ---
        jjrm = "jj rebase -s @ -d master@origin";
        jjnm = {
          expansion = "jj new master@origin -m \"%\"";
          setCursor = true;
        };

        # Archives
        # ---
        zip = {
          expansion = "ouch compress %<files> output.zip";
          setCursor = true;
        };
        unzip = "ouch decompress";
        unzipToDir = {
          expansion = "ouch decompress -d %<dir> X.zip";
          setCursor = true;
        };

        # Image/Video conversions
        # ---
        iconvert = {
          expansion = "magick % output.png"; # imagemagick
          setCursor = true;
        };

        vconvert = {
          expansion = "ffmpeg -i % output.mp4";
          setCursor = true;
        };
      };

      plugins = let
        fishP = name: {
          inherit name;
          inherit (pkgs.fishPlugins.${name}) src;
        };
      in [
        (fishP "fifc") # fzf for autocomplete e.g. params
        # interactive selectors for git
        # See https://github.com/wfxr/forgit for list
        (fishP "forgit")
      ];
    };

    home.packages = with pkgs; [
      fzf # required by fifc, not used universally
    ];
  };
}
