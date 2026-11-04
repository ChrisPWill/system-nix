{
  config,
  pkgs,
  ...
}: {
  programs = {
    zsh.initContent = ''
      typeset -ga zvm_after_init_commands
      zvm_after_init_commands+=("zvm_bindkey viins '^T' tv-smart-autocomplete")
    '';

    # FZF replacement
    # Use Ctrl-T for smart finding on lots of commands
    television = {
      enable = config.appApproved.television;
      settings = {
        ui.theme = "onedark";
        shell_integration.channel_triggers = {
          "files" = [
            "nvim"
            "hx"
            "helix"
            "meow"
          ];
          "git-repos" = [
            "code"
            "git clone"
          ];
        };
      };
    };

    nix-search-tv = {
      enable = config.appApproved.nix-search-tv;
      enableTelevisionIntegration = config.appApproved.television;
    };
  };

  home.packages = config.filterApproved {
    inherit
      (pkgs)
      tealdeer
      nix-search-cli # useful for searching for packages
      ;
  };
}
