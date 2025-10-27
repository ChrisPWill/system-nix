{
  pkgs,
  config,
  # osConfig,
  ...
}: {
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

  programs = {
    # Command history manager
    # https://github.com/atuinsh/atuin
    atuin.enable = true;
    atuin.enableZshIntegration = true;
    atuin.daemon.enable = true;

    # Nice colourful cat alternative
    # https://github.com/sharkdp/bat
    bat.enable = true;

    # ls alternative
    # https://github.com/eza-community/eza
    eza.enable = true;
    eza.git = true;
    eza.icons = "auto";

    # Command line fuzzy finder
    # https://github.com/junegunn/fzf
    # Hotkeys:
    # CTRL-T find a file/dir and put it in command line
    # CTRL-R search command history
    # ALT-C to cd into a subdir
    fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "fd --hidden";
      changeDirWidgetCommand = "fd --type d";
      fileWidgetCommand = "fd --type f";
    };

    git = {
      enable = true;
      userName = "Chris Williams";

      lfs.enable = true;
      diff-so-fancy = {
        enable = true;
      };

      extraConfig = {
        push.autoSetupRemote = true;
        core = {
          # Improved performance on MacOS
          # https://github.blog/2022-06-29-improve-git-monorepo-performance-with-a-file-system-monitor/
          fsmonitor = true;
          untrackedcache = true;
        };
      };
    };

    wezterm.enable = true;
    wezterm.enableZshIntegration = true;

    # Nice fast autojump command
    # https://github.com/ajeetdsouza/zoxide
    zoxide.enable = true;
    zoxide.enableZshIntegration = true;

    # Terminal multiplexer
    # https://zellij.dev
    zellij.enable = true;
    zellij.settings = {
      scroll_buffer_size = 10000;
      copy_on_select = true;
      pane_frames = false;
    };
    zsh.shellAliases.zz = "f() { zellij attach -c ''\${1:-default} };f";
    zsh.shellAliases.zr = "zellij run --";
    zsh.shellAliases.rf = "zellij run --floating --";
    zsh.shellAliases.a = "f() { zellij attach ''\${1:-default} };f";
    zsh.shellAliases.l = "zellij list-sessions";
    zsh.shellAliases.k = "zellij kill-session";
    zsh.shellAliases.ka = "zellij kill-all-sessions";

    zsh = {
      enable = true;

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
  };

  home.stateVersion = "25.05";
}
