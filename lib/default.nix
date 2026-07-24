_: {
  languageTooling = {
    perSystem,
    pkgs,
  }: let
    inherit (pkgs) lib;

    stacks = rec {
      nix = with pkgs; [
        nixd
        alejandra
        statix
        deadnix
      ];

      shell = with pkgs; [
        bash-language-server
        fish-lsp
        shellcheck
        shfmt
        tombi
        yaml-language-server
        vscode-langservers-extracted
        marksman
        prettierd
      ];

      lua = [
        pkgs.lua
        pkgs.lua-language-server
        pkgs.stylua
      ];

      python = with pkgs; [
        python314
        python314Packages.debugpy
        python314Packages.pytest
        basedpyright
        ruff
      ];

      rust = with pkgs; [
        cargo
        rustc
        rust-analyzer
        rustfmt
        clippy
        lldb
      ];

      go = [
        pkgs.go
        pkgs.gopls
        pkgs.go-tools
        pkgs.delve
        pkgs.golangci-lint
      ];

      cpp = with pkgs; [
        llvm
        clang
        clang-tools
        gdb
        lldb
        cmake
        ninja
        gnumake
        pkg-config
        cppcheck
      ];

      jvm = with pkgs; [
        jdk21
        kotlin
        perSystem.self.kotlin-lsp
        jdt-language-server
        google-java-format
      ];

      nodeCommon = with pkgs; [
        typescript
        typescript-language-server
        eslint_d
        prettier
        prettierd
        vscode-langservers-extracted
        yaml-language-server
        tailwindcss
        tailwindcss-language-server
        graphql-language-service-cli
        vscode-js-debug
      ];

      node22 =
        [
          pkgs.nodejs_22
          (pkgs.yarn.override {nodejs = pkgs.nodejs_22;})
        ]
        ++ nodeCommon;

      node24 =
        [
          pkgs.nodejs_24
          (pkgs.yarn.override {nodejs = pkgs.nodejs_24;})
        ]
        ++ nodeCommon;
    };

    namedStackNames = [
      "nix"
      "shell"
      "lua"
      "python"
      "rust"
      "go"
      "cpp"
      "jvm"
      "node22"
      "node24"
    ];

    packagesFor = names:
      lib.concatMap (name: stacks.${name}) names;

    mkShell = {
      stacks ? [],
      extraPackages ? [],
      env ? {},
      shellHook ? "",
    }:
      pkgs.mkShell {
        packages = packagesFor stacks ++ extraPackages;
        inherit env shellHook;
      };
  in {
    inherit stacks namedStackNames packagesFor mkShell;
  };
}
