{
  pkgs,
  config,
  inputs,
  lib,
  # osConfig,
  ...
}: {
  options = with lib; {
    nixConfigDir = mkOption {
      type = types.str;
      description = "The directory containing the nix configuration";
      default = "${config.home.homeDirectory}/.system-nix";
    };

    homeModuleDir = mkOption {
      type = types.str;
      description = "The directory containing the home module";
      default = "${config.nixConfigDir}/modules/home";
    };
  };

  imports = [
    ./theme.nix

    # Temporary until moved to nixCats
    inputs.nixvim.homeModules.nixvim
    ./nixvim
  ];

  config = {
    nix.settings.experimental-features = ["nix-command" "flakes"];

    # only available on linux, disabled on macos
    services.ssh-agent.enable = pkgs.stdenv.isLinux;

    home.packages =
      # Must-have packages for all systems
      with pkgs;
        [
          # Fast alternative to find
          # https://github.com/sharkdp/fd
          fd

          # A good font
          nerd-fonts.fantasque-sans-mono

          # Fast grep
          ripgrep

          # Runs with "tldr" - quick facts about an app
          # https://github.com/dbrgn/tealdeer
          tealdeer
        ]
        # Can access the host configuration using osConfig e.g.
        # ++ (
        #   pkgs.lib.optionals (osConfig.programs.vim.enable && pkgs.stdenv.isDarwin) [skhd]
        # )
        ++ (
          # Linux-specific packages
          pkgs.lib.optionals (pkgs.stdenv.isLinux) []
        )
        ++ (
          # MacOS-specific packages
          pkgs.lib.optionals (pkgs.stdenv.isDarwin) []
        );

    # Command history manager
    # https://github.com/atuinsh/atuin
    programs.atuin.enable = true;
    programs.atuin.enableZshIntegration = true;
    programs.atuin.daemon.enable = true;

    # Nice colourful cat alternative
    # https://github.com/sharkdp/bat
    programs.bat.enable = true;

    # ls alternative
    # https://github.com/eza-community/eza
    programs.eza.enable = true;
    programs.eza.git = true;
    programs.eza.icons = "auto";

    # Command line fuzzy finder
    # https://github.com/junegunn/fzf
    # Hotkeys:
    # CTRL-T find a file/dir and put it in command line
    # CTRL-R search command history
    # ALT-C to cd into a subdir
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "fd --hidden";
      changeDirWidgetCommand = "fd --type d";
      fileWidgetCommand = "fd --type f";
    };

    programs.git = {
      enable = true;

      lfs.enable = true;

      settings = {
        user.name = "Chris Williams";
        push.autoSetupRemote = true;
        core = {
          # Improved performance on MacOS
          # https://github.blog/2022-06-29-improve-git-monorepo-performance-with-a-file-system-monitor/
          fsmonitor = true;
          untrackedcache = true;
        };
      };
    };
    programs.diff-so-fancy.enable = true;
    programs.diff-so-fancy.enableGitIntegration = true;

    # Modern alternative prompt
    programs.starship.enable = true;
    programs.starship.enableZshIntegration = true;

    programs.wezterm.enable = true;
    programs.wezterm.enableZshIntegration = true;
    # Copy the wezterm.lua file to the home module directory
    xdg.configFile."wezterm/extraWezterm.lua".source = config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/out-of-store/wezterm.lua";
    programs.wezterm.extraConfig = "local extraConfig = require('extraWezterm'); return extraConfig";

    # Nice fast autojump command
    # https://github.com/ajeetdsouza/zoxide
    programs.zoxide.enable = true;
    programs.zoxide.enableZshIntegration = true;

    # Terminal multiplexer
    # https://zellij.dev
    programs.zellij.enable = true;
    programs.zellij.settings = {
      scroll_buffer_size = 10000;
      copy_on_select = true;
      pane_frames = false;
    };
    programs.zsh.shellAliases.zz = "f() { zellij attach -c ''\${1:-default} };f";
    programs.zsh.shellAliases.zr = "zellij run --";
    programs.zsh.shellAliases.rf = "zellij run --floating --";
    programs.zsh.shellAliases.a = "f() { zellij attach ''\${1:-default} };f";
    programs.zsh.shellAliases.l = "zellij list-sessions";
    programs.zsh.shellAliases.k = "zellij kill-session";
    programs.zsh.shellAliases.ka = "zellij kill-all-sessions";

    programs.zsh = {
      enable = true;

      plugins = [
        {
          name = "vi-mode";
          src = pkgs.zsh-vi-mode;
          file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
        }
      ];

      dotDir = "${config.home.homeDirectory}/.config/zsh";

      history = {
        size = 10000;
        save = 10000;
        path = "$HOME/.config/zsh/.zshinfo";
        share = true;

        ignoreSpace = true;
        ignoreDups = true;
        extended = true;
        expireDuplicatesFirst = true;
      };

      # Useful directory navigation aliases
      shellAliases.".." = "cd ..";
      shellAliases."..." = "cd ../..";
      shellAliases."...." = "cd ../../..";
      shellAliases."-- -" = "cd -";
      shellAliases."-- --" = "cd -2";
      shellAliases."-- ---" = "cd -3";
    };

    # Aerospace window manager config
    xdg.configFile."aerospace/aerospace.toml".source = config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/out-of-store/aerospace.toml";

    home.stateVersion = "25.05";
  };
}
