{pkgs, ...}: {
  programs.zsh.initContent = ''
    typeset -ga zvm_after_init_commands
    zvm_after_init_commands+=("zvm_bindkey viins '^T' tv-smart-autocomplete")
  '';

  home.packages = with pkgs; [
    tealdeer
    nix-search-cli # useful for searching for packages
  ];

  # FZF replacement
  # Use Ctrl-T for smart finding on lots of commands
  programs.television = {
    enable = true;
    settings = {
      ui.theme = "onedark";
    };
  };

  programs.nix-search-tv.enable = true;
  programs.nix-search-tv.enableTelevisionIntegration = true;
}
