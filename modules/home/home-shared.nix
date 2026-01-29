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
    isAtlassianMachine = mkEnableOption "Atlassian work machine packages/config";
  };

  imports = [
    ./nixCats
    ./fonts.nix

    # https://github.com/dfrankland/envoluntary
    # direnv-like matcher that avoids needing to create gitignored nix files in projects
    inputs.envoluntary.homeModules.default
    ({pkgs, ...}: {programs.envoluntary.package = inputs.envoluntary.packages.${pkgs.stdenv.hostPlatform.system}.default;})

    # Terminal multiplexer
    # https://zellij.dev
    ./programs/zellij.nix

    # Nushell, modern non-POSIX shell
    ./programs/nushell.nix

    # git and jujutsu settings
    ./programs/version-control.nix

    ./programs/sketchybar
  ];

  config = {
    nix.settings.experimental-features = ["nix-command" "flakes"];

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

          # TUI to browse quite a few journals/logs.
          # Great for docker, journald, systemd logs etc.
          # https://github.com/Lifailon/lazyjournal
          lazyjournal

          # JSON formatting etc.
          jq

          # Note taking
          logseq

          # Rust-based ps replacement
          procs
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
    };

    # Command line fuzzy finder
    # https://github.com/junegunn/fzf
    # Hotkeys:
    # CTRL-T find a file/dir and put it in command line
    # CTRL-R search command history
    # ALT-C to cd into a subdir
    programs.fzf = {
      enable = true;
      defaultCommand = "fd --hidden";
      changeDirWidgetCommand = "fd --type d";
      fileWidgetCommand = "fd --type f";
    };

    # Useful home-manager alias if enabled
    programs.zsh.shellAliases."hms" = lib.mkIf config.programs.home-manager.enable "home-manager switch --flake ${config.nixConfigDir}/.";
    programs.nushell.shellAliases."hms" = lib.mkIf config.programs.home-manager.enable "home-manager switch --flake ${config.nixConfigDir}/.";
    # darwin-rebuild alias added for MacOS systems
    programs.zsh.shellAliases."drs" = lib.mkIf pkgs.stdenv.isDarwin "sudo /run/current-system/sw/bin/darwin-rebuild switch --flake ${config.nixConfigDir}/.";
    programs.nushell.shellAliases."drs" = lib.mkIf pkgs.stdenv.isDarwin "sudo /run/current-system/sw/bin/darwin-rebuild switch --flake ${config.nixConfigDir}/.";
    # nixos-rebuild alias added for NixOS systems
    programs.zsh.shellAliases."nrs" = lib.mkIf (pkgs.stdenv.isLinux && !config.programs.home-manager.enable) "sudo nixos-rebuild switch --flake ${config.nixConfigDir}/.";
    programs.nushell.shellAliases."nrs" = lib.mkIf (pkgs.stdenv.isLinux && !config.programs.home-manager.enable) "sudo nixos-rebuild switch --flake ${config.nixConfigDir}/.";

    # Quick alias to enable a devshell
    programs.zsh.shellAliases."nd" = "f() { nix develop ${config.nixConfigDir}/.#$1 --command zsh };f";

    # Modern alternative prompt
    programs.starship.enable = true;
    programs.starship.settings = {
      right_format = "$os$shell$git_status$git_metrics$memory_usage";
      command_timeout = 1000;

      cmd_duration = {
        min_time = 200;
      };

      # Show added/deleted git lines
      git_metrics = {
        disabled = false;
      };

      memory_usage = {
        disabled = false;
        threshold = 90; # percentage
      };

      os = {
        disabled = false;
      };

      os.symbols = {
        Macos = " ";
        NixOS = " ";
        Windows = " ";
      };

      # Shows current shell
      shell = {
        disabled = false;
      };

      # Shows exit code of last command if non-zero
      status = {
        disabled = false;
      };
    };

    programs.wezterm.enable = true;
    # Copy the wezterm.lua file to the home module directory
    xdg.configFile."wezterm/extraWezterm.lua".source = config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/out-of-store/wezterm.lua";
    programs.wezterm.extraConfig = "local extraConfig = require('extraWezterm'); return extraConfig";

    programs.yazi = {
      enable = true;

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

    # Autocompletion in shell
    programs.carapace.enable = true;

    # Command history
    programs.atuin.enable = true;

    # Aerospace window manager config
    xdg.configFile."aerospace/aerospace.toml" = lib.mkIf pkgs.stdenv.isDarwin {
      source = config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/out-of-store/aerospace.toml";
    };

    home.stateVersion = "25.05";
  };
}
