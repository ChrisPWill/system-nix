{
  config,
  lib,
  ...
}: let
  # Every app this repository can install, one name per tool. A locked-down
  # machine installs only the ones it approves (see approvedApps). Plugins and
  # runtime dependencies bundled into an app come with it; standalone tools an
  # app calls get their own name. Fonts, theming and Home Manager itself are
  # not apps. Home Manager and nix-darwin both import this module, so one set
  # of names covers both. checks/approved-apps.nix enforces the gating.
  gatedApps = [
    # Shells and prompt
    "atuin"
    "carapace"
    "fastfetch"
    "fish"
    "forgit"
    "fzf"
    "nushell"
    "starship"
    "zsh"
    "zsh-vi-mode"

    # Command-line tools
    "bat"
    "btop"
    "direnv"
    "envoluntary"
    "eza"
    "fd"
    "glow"
    "google-cloud-sdk"
    "gum"
    "jq"
    "lazyjournal"
    "macmon"
    "nix-search-cli"
    "nix-search-tv"
    "ouch"
    "p7zip"
    "procs"
    "progress"
    "ripgrep"
    "tealdeer"
    "television"
    "viddy"
    "websocat"
    "wget"
    "yazi"
    "zenity"
    "zoxide"

    # Nix
    "nh"

    # Version control and SSH
    "diff-so-fancy"
    "gh"
    "git"
    "git-lfs"
    "jjui"
    "jujutsu"
    "lazygit"
    "ssh-agent"
    "tig"

    # Editors, terminals and multiplexers
    "foot"
    "ghostty"
    "helix"
    "man-db"
    "neovim"
    "wezterm"
    "zellij"

    # Language servers, formatters, linters and debuggers
    "alejandra"
    "basedpyright"
    "bash-language-server"
    "clang-tools"
    "deadnix"
    "fish-lsp"
    "gdb"
    "go-tools"
    "gopls"
    "kotlin-lsp"
    "lldb"
    "lua-language-server"
    "marksman"
    "nixd"
    "prettierd"
    "ruff"
    "rust-analyzer"
    "rustfmt"
    "shellcheck"
    "shfmt"
    "statix"
    "stylua"
    "typescript-language-server"
    "vscode-langservers-extracted"
    "yaml-language-server"

    # Language runtimes and containers
    "colima"
    "mise"
    "nodejs"

    # AI
    "claude"
    "chatgpt"
    "claude-code"
    "codex"
    "gemini-cli"
    "graphiti"
    "ollama"
    "opencode"

    # Secrets and sync
    "sops"
    "syncthing"

    # Media and documents
    "ffmpeg"
    "imagemagick"
    "logseq"
    "spotify"
    "zathura"

    # Desktop apps
    "asyar"
    "cleanshot"
    "element"
    "imageoptim"
    "kanata"
    "omniwm"
    "scroll-reverser"
    "skhd"
    "t3code"
    "vivaldi"
  ];
in {
  options = with lib; {
    approvedApps = mkOption {
      type = types.nullOr (types.listOf (types.enum gatedApps));
      default = null;
      example = ["git" "neovim"];
      description = ''
        Apps a locked-down machine may install. On employer laptops where each
        app needs IT approval, set this to the approved names; apps not listed
        are left out. Null approves every app.
      '';
    };

    appApproved = mkOption {
      type = types.attrsOf types.bool;
      readOnly = true;
      # Modules read `config.appApproved.<name>` rather than searching the
      # list, so a misspelt name fails evaluation instead of silently gating
      # the app off.
      default = genAttrs gatedApps (name: config.approvedApps == null || elem name config.approvedApps);
      description = "Whether each app is approved on this machine. Derived from approvedApps.";
    };

    filterApproved = mkOption {
      type = types.raw;
      readOnly = true;
      default = apps: attrValues (filterAttrs (name: _: config.appApproved.${name}) apps);
      description = ''
        Takes an attribute set from app name to value, such as a package, and
        returns the values of approved apps as a list. For gating a package
        list one tool at a time.
      '';
    };
  };
}
