{
  pkgs,
  lib,
  ...
}: {
  imports = [
    (import ./plugins/default.nix {utils = import ./utils.nix {};})
    ./colorscheme.nix
  ];

  options = {
    programs.nixvim.custom = {
      enableCopilot = lib.mkEnableOption "Enable Copilot in Neovim";
    };
  };

  config.programs.nixvim = {
    enable = true;
    defaultEditor = true;

    clipboard.register = "unnamedplus";
    clipboard.providers.wl-copy.enable = pkgs.stdenv.isLinux;
    clipboard.providers.wl-copy.package = pkgs.wl-clipboard-rs;
    extraPackages = with pkgs; ([]
      ++ lib.optionals pkgs.stdenv.isLinux [
        wl-clipboard-rs
      ]);

    opts = {
      swapfile = false; # don't create swap files

      autowrite = true; # autowrite when changing buffer
      termguicolors = true;

      cursorline = true; # highlight the current line
      undofile = true; # enable undo files to persist across sessions

      ignorecase = true; # ignore case in search
      smartcase = true; # case sensitive if any uppercase is used

      # tabs and spacing
      tabstop = 2; # number of spaces that a <Tab> counts for
      shiftwidth = 2; # number of spaces for each step of autoindent
      expandtab = true; # use spaces to insert a tab

      # indents
      autoindent = true; # copy indent from current line when starting a new line
      smartindent = true; # smart autoindenting based on syntax

      # wraps
      breakindent = true;
      breakindentopt = "sbr,shift:1"; # shows the showbreak character, shifts by 1
      showbreak = "↪ ";

      # line numbers and other column UI
      signcolumn = "yes"; # show sign column by default (for diagnostics)
      number = true;
    };

    # Performance tweaks
    luaLoader.enable = true;
    performance = {
      # https://nix-community.github.io/nixvim/performance/combinePlugins.html
      # If there are naming collisions, can use the standalonePlugins option
      combinePlugins.enable = false;
      combinePlugins.standalonePlugins = [
        "nvim-treesitter"
        "nvim-treesitter-textobjects"
        "mini.nvim"
        "copilot.lua"
      ];
      byteCompileLua = {
        enable = true;
        nvimRuntime = true;
        configs = true;
        plugins = true;
      };
    };
  };
}
