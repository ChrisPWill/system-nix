{
  pkgs,
  config,
  inputs,
  lib,
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

    userEmail = mkOption {
      type = types.str;
      description = "The email address of the user";
      default = "chris@chrispwill.com";
    };

    isPersonalMachine = mkEnableOption "personal machine packages/config";
  };

  imports = [
    ./nixCats
    ./fonts.nix

    # https://github.com/dfrankland/envoluntary
    # direnv-like matcher that avoids needing to create gitignored nix files in projects
    inputs.envoluntary.homeModules.default
    ({pkgs, ...}: {programs.envoluntary.package = inputs.envoluntary.packages.${pkgs.stdenv.hostPlatform.system}.default;})
  ];

  config = {
    nix.settings.experimental-features = ["nix-command" "flakes"];

    services.ssh-agent.enable = true;
    services.ssh-agent.enableZshIntegration = true;
    services.ssh-agent.enableFishIntegration = true;
    services.ssh-agent.enableNushellIntegration = true;
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      extraConfig = lib.optionalString pkgs.stdenv.isDarwin ''
        IgnoreUnknown UseKeychain
        UseKeychain yes
      '';

      matchBlocks = {
        "*" = {
          addKeysToAgent = "yes";
          compression = true;
          forwardAgent = true;
          serverAliveCountMax = 2;
          serverAliveInterval = 300;
        };
      };
    };

    home.packages =
      # Must-have packages for all systems
      # Note: can use perSystem.nixpkgs-small.<package> if a bugfix is recently merged and I want to get it sooner
      with pkgs;
        [
          # Fast alternative to find
          # https://github.com/sharkdp/fd
          fd

          # Fast grep
          ripgrep

          # Runs with "tldr" - quick facts about an app
          # https://github.com/dbrgn/tealdeer
          tealdeer

          # Neat TUI for jujutsu
          # https://github.com/Cretezy/lazyjj
          lazyjj

          # TUI to browse quite a few journals/logs.
          # Great for docker, journald, systemd logs etc.
          # https://github.com/Lifailon/lazyjournal
          lazyjournal

          # JSON formatting etc.
          jq

          # Note taking
          logseq

          # Another fancy git UI
          tig
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

    # Nice colourful cat alternative
    # https://github.com/sharkdp/bat
    programs.bat.enable = true;

    # ls alternative
    # https://github.com/eza-community/eza
    programs.eza.enable = true;
    programs.eza.git = true;
    programs.eza.icons = "auto";

    programs.envoluntary = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };

    # Command line fuzzy finder
    # https://github.com/junegunn/fzf
    # Hotkeys:
    # CTRL-T find a file/dir and put it in command line
    # CTRL-R search command history
    # ALT-C to cd into a subdir
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      defaultCommand = "fd --hidden";
      changeDirWidgetCommand = "fd --type d";
      fileWidgetCommand = "fd --type f";
    };

    programs.git = {
      enable = true;

      lfs.enable = true;

      settings = {
        user.name = "Chris Williams";
        user.email = config.userEmail;
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

    # Neat TUI for git
    # https://github.com/jesseduffield/lazygit
    programs.lazygit.enable = true;
    programs.lazygit.enableZshIntegration = true;
    programs.lazygit.enableFishIntegration = true;
    programs.lazygit.enableNushellIntegration = true;
    programs.zsh.shellAliases.lg = "lazygit";

    # Useful home-manager alias if enabled
    programs.zsh.shellAliases."hms" = lib.mkIf config.programs.home-manager.enable "home-manager switch --flake ${config.nixConfigDir}/.";
    # darwin-rebuild alias added for MacOS systems
    programs.zsh.shellAliases."drs" = lib.mkIf pkgs.stdenv.isDarwin "sudo /run/current-system/sw/bin/darwin-rebuild switch --flake ${config.nixConfigDir}/.";
    # nixos-rebuild alias added for NixOS systems
    programs.zsh.shellAliases."nrs" = lib.mkIf (pkgs.stdenv.isLinux && !config.programs.home-manager.enable) "sudo nixos-rebuild switch --flake ${config.nixConfigDir}/.";

    # Quick alias to enable a devshell
    programs.zsh.shellAliases."nd" = "f() { nix develop ${config.nixConfigDir}/.#$1 --command zsh };f";

    # https://jj-vcs.github.io/jj/latest/
    # VCS built on top of git
    # Experimenting with this for personal projects
    programs.jujutsu.enable = true;
    programs.jujutsu.settings.user.name = "Chris Williams";
    programs.jujutsu.settings.user.email = config.userEmail;
    # LazyJJ - easy TUI for jujutsu VCS
    programs.zsh.shellAliases.ljj = "lazyjj";

    # Modern alternative prompt
    programs.starship.enable = true;
    programs.starship.enableZshIntegration = true;
    programs.starship.enableFishIntegration = true;
    programs.starship.enableNushellIntegration = true;

    programs.wezterm.enable = true;
    programs.wezterm.enableZshIntegration = true;
    # Copy the wezterm.lua file to the home module directory
    xdg.configFile."wezterm/extraWezterm.lua".source = config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/out-of-store/wezterm.lua";
    programs.wezterm.extraConfig = "local extraConfig = require('extraWezterm'); return extraConfig";

    programs.yazi = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;

      extraPackages = with pkgs; [
        ouch
        glow
      ];

      plugins = let
        yz = pkgs.yaziPlugins;
      in {
        git = yz.git; # Git status
        sudo = yz.sudo; # Call sudo
        ouch = yz.ouch; # Preview archives
        glow = yz.glow; # Preview markdown files
        mount = yz.mount; # Mount manager
        starship = yz.starship; # Starship prompt integration
        relative-motions = yz."relative-motions"; # Vim-like motions
      };
    };

    # Nice fast autojump command
    # https://github.com/ajeetdsouza/zoxide
    programs.zoxide.enable = true;
    programs.zoxide.enableZshIntegration = true;
    programs.zoxide.enableFishIntegration = true;
    programs.zoxide.enableNushellIntegration = true;

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
    programs.zsh.shellAliases.zrf = "zellij run --floating --";
    programs.zsh.shellAliases.za = "f() { zellij attach ''\${1:-default} };f";
    programs.zsh.shellAliases.zl = "zellij list-sessions";
    programs.zsh.shellAliases.zk = "zellij kill-session";
    programs.zsh.shellAliases.zka = "zellij kill-all-sessions";

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
    };
    # Useful directory navigation aliases
    programs.zsh.shellAliases.".." = "cd ..";
    programs.zsh.shellAliases."..." = "cd ../..";
    programs.zsh.shellAliases."...." = "cd ../../..";
    programs.zsh.shellAliases."-- -" = "cd -";
    programs.zsh.shellAliases."-- --" = "cd -2";
    programs.zsh.shellAliases."-- ---" = "cd -3";

    programs.fish.enable = true;

    programs.nushell = {
      enable = true;
    };

    programs.carapace.enable = true;
    programs.carapace.enableZshIntegration = true;
    programs.carapace.enableFishIntegration = true;
    programs.carapace.enableNushellIntegration = true;

    # Aerospace window manager config
    xdg.configFile."aerospace/aerospace.toml" = lib.mkIf pkgs.stdenv.isDarwin {
      source = config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/out-of-store/aerospace.toml";
    };

    home.stateVersion = "25.05";
  };
}
