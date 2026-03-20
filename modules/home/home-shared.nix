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
    ./fonts.nix

    # https://github.com/dfrankland/envoluntary
    # direnv-like matcher that avoids needing to create gitignored nix files in projects
    inputs.envoluntary.homeModules.default
    ({pkgs, ...}: {programs.envoluntary.package = inputs.envoluntary.packages.${pkgs.stdenv.hostPlatform.system}.default;})

    # Terminal multiplexer
    # https://zellij.dev
    ./programs/zellij

    # My neovim setup
    ./programs/neovim

    # Nushell, modern non-POSIX shell
    ./programs/nushell.nix

    # Fish, a modern shell
    ./programs/fish.nix

    # git and jujutsu settings
    ./programs/version-control.nix

    ./programs/wezterm
    ./programs/aerospace

    ./programs/sketchybar

    ./services/ollama.nix

    ./programs/gemini.nix
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

          # Easy zipper/unzipper
          ouch

          # Rust-based ps replacement
          procs

          # Watch progress of cp/mv/dd/tar/etc. `tldr progress` for info
          progress

          # Conversions etc.
          imagemagick
          ffmpeg
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

    home.sessionPath = ["${config.homeModuleDir}/scripts"];
    programs.nushell.extraEnv = ''
      $env.PATH = ($env.PATH | split row (char esep) | append "${config.homeModuleDir}/scripts")
    '';

    # Nice colourful cat alternative
    # https://github.com/sharkdp/bat
    programs.bat.enable = true;

    # Auto use flakes when in directory (and allowed)
    # Remember to `direnv allow` in a project to get it going
    programs.direnv.enable = true;

    # ls alternative
    # https://github.com/eza-community/eza
    programs.eza.enable = true;
    programs.eza.git = true;
    programs.eza.icons = "auto";

    programs.envoluntary.enable = true;

    # FZF replacement
    # Use Ctrl-T for smart finding on lots of commands
    programs.television = {
      enable = true;

      settings = {
        ui.theme = "onedark";
      };
    };

    # Helix for when I feel like switching it up
    programs.helix.enable = true;

    # Useful home-manager alias if enabled
    programs.zsh.shellAliases."hms" = lib.mkIf config.programs.home-manager.enable "home-manager switch --flake ${config.nixConfigDir}/.";
    programs.fish.shellAliases."hms" = lib.mkIf config.programs.home-manager.enable "home-manager switch --flake ${config.nixConfigDir}/.";
    programs.nushell.shellAliases."hms" = lib.mkIf config.programs.home-manager.enable "home-manager switch --flake ${config.nixConfigDir}/.";
    # darwin-rebuild alias added for MacOS systems
    programs.zsh.shellAliases."drs" = lib.mkIf pkgs.stdenv.isDarwin "sudo /run/current-system/sw/bin/darwin-rebuild switch --flake ${config.nixConfigDir}/.";
    programs.fish.shellAliases."drs" = lib.mkIf pkgs.stdenv.isDarwin "sudo /run/current-system/sw/bin/darwin-rebuild switch --flake ${config.nixConfigDir}/.";
    programs.nushell.shellAliases."drs" = lib.mkIf pkgs.stdenv.isDarwin "sudo /run/current-system/sw/bin/darwin-rebuild switch --flake ${config.nixConfigDir}/.";
    # nixos-rebuild alias added for NixOS systems
    programs.zsh.shellAliases."nrs" = lib.mkIf (pkgs.stdenv.isLinux && !config.programs.home-manager.enable) "sudo nixos-rebuild switch --flake ${config.nixConfigDir}/.";
    programs.fish.shellAliases."nrs" = lib.mkIf (pkgs.stdenv.isLinux && !config.programs.home-manager.enable) "sudo nixos-rebuild switch --flake ${config.nixConfigDir}/.";
    programs.nushell.shellAliases."nrs" = lib.mkIf (pkgs.stdenv.isLinux && !config.programs.home-manager.enable) "sudo nixos-rebuild switch --flake ${config.nixConfigDir}/.";

    # Quick alias to enable a devshell
    programs.zsh.shellAliases."nd" = "f() { nix develop ${config.nixConfigDir}/.#$1 --command zsh };f";

    # Modern alternative prompt
    programs.starship.enable = true;
    programs.starship.settings = {
      right_format = "$os$shell$git_status$git_metrics$memory_usage";
      command_timeout = 1000;

      cmd_duration.min_time = 200;

      # Show added/deleted git lines
      git_metrics.disabled = false;

      memory_usage.disabled = false;
      memory_usage.threshold = 90; # percentage

      os.disabled = false;

      os.symbols = {
        Macos = " ";
        NixOS = " ";
        Windows = " ";
      };

      # Shows current shell
      shell.disabled = false;

      # Shows exit code of last command if non-zero
      status.disabled = false;
    };

    programs.yazi = {
      enable = true;

      shellWrapperName = "y";

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

    # PDF viewer
    programs.zathura.enable = true;

    # Nice fast autojump command
    # https://github.com/ajeetdsouza/zoxide
    programs.zoxide.enable = true;

    programs.zsh = {
      enable = true;
      completionInit = ''
        autoload -Uz compinit
        if [[ -n ''${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
          compinit
        else
          compinit -C
        fi
        if [[ ! -f ''${ZDOTDIR:-$HOME}/.zcompdump.zwc || \
              ''${ZDOTDIR:-$HOME}/.zcompdump -nt ''${ZDOTDIR:-$HOME}/.zcompdump.zwc ]]; then
          zcompile ''${ZDOTDIR:-$HOME}/.zcompdump
        fi
      '';

      initContent = ''
        tv-nvim-widget() {
          # Notify ZLE that we are going to use the terminal
          zle -I

          # Run the command with stdin redirected to the terminal
          # Also, use 'command' if it's a binary, or ensure the function is defined
          tv-nvim < /dev/tty

          # Redraw the prompt so your line doesn't look broken
          zle reset-prompt
        }

        zle -N tv-nvim-widget

        # Define extra bindings for zsh-vi-mode
        function zvm_after_init() {
          zvm_bindkey viins '^[o' tv-nvim-widget
          # Re-bind Atuin and Television which are often clobbered by vi-mode
          zvm_bindkey viins '^R' atuin-search-viins
          zvm_bindkey viins '^T' tv-smart-autocomplete
        }
      '';

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

    # Matrix chat
    programs.element-desktop.enable = true;

    home.stateVersion = "25.05";
  };
}
