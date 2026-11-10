# Apps IT has approved for this laptop. Nothing installs unless it's named
# here, including command-line tools. Add a name once it's approved, then run
# `sw` (and `sw-system` for apps nix-darwin installs). The names you can use are
# gatedApps in modules/shared/approved-apps.nix; a misspelt name stops the
# build. Both users/cwilliams82.nix and darwin-configuration.nix read this list.
[
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
  "direnv"
  "envoluntary"
  "eza"
  "fd"
  "glow"
  "gum"
  "jq"
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
  "wget"
  "yazi"
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

  # Language runtimes
  "colima"
  "mise"

  # AI
  "claude-code"
  "codex"

  # Desktop apps
  "asyar"
  "omniwm"
  "kanata"
  # "raycast"
  "scroll-reverser"
  "skhd"
]
