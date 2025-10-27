{config, ...}: {
  programs.nixvim = {
    plugins.treesitter = {
      enable = true;
      nixvimInjections = true;
      nixGrammars = true;
      settings = {
        indent.enable = true;
      };
    };

    plugins.treesitter-context = {
      enable = true;
      settings.separator = "-";
    };
    highlight = with config.theme; {
      TreesitterContext = {
        fg = foreground;
        bg = "NONE";
      };
      TreesitterContextSeparator = {
        fg = foreground;
        bg = "NONE";
      };
    };

    plugins.rainbow-delimiters.enable = true;
  };
}
