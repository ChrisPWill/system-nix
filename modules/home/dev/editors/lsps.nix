{pkgs, ...}: {
  # Mirroring the LSP/Formatter setup from Neovim
  home.packages = with pkgs; [
    # Nix
    nixd
    alejandra

    # Python
    basedpyright
    ruff

    # Rust (usually in devshell, but good to have)
    rust-analyzer
    rustfmt

    # Go
    gopls
    gotools
    go-tools

    # Lua
    lua-language-server
    stylua

    # Web/JS/TS
    typescript-language-server
    prettierd
    vscode-langservers-extracted # HTML/CSS/JSON
    yaml-language-server

    # Shell
    bash-language-server
    shellcheck
    shfmt
    fish-lsp

    # C++
    clang-tools
    gdb
    lldb

    # Markdown
    marksman
  ];
}
