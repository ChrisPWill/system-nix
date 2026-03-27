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
    ./programs/shells/shared.nix

    # https://github.com/dfrankland/envoluntary
    # direnv-like matcher that avoids needing to create gitignored nix files in projects
    inputs.envoluntary.homeModules.default
    ({pkgs, ...}: {programs.envoluntary.package = inputs.envoluntary.packages.${pkgs.stdenv.hostPlatform.system}.default;})

    # Terminal multiplexer
    # https://zellij.dev
    ./programs/zellij

    # My neovim setup
    ./programs/neovim

    ./programs/shells/zsh.nix
    ./programs/shells/nushell.nix
    ./programs/shells/fish.nix

    # git and jujutsu settings
    ./programs/version-control.nix

    ./programs/helix

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

    programs.envoluntary.enable = true;

    # FZF replacement
    # Use Ctrl-T for smart finding on lots of commands
    programs.television = {
      enable = true;

      settings = {
        ui.theme = "onedark";
      };
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

    # Matrix chat
    programs.element-desktop.enable = true;

    home.stateVersion = "25.05";
  };
}
