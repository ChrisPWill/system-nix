{
  perSystem,
  pkgs,
  ...
}: let
  languageTooling = (import ../lib {}).languageTooling {inherit perSystem pkgs;};
  commands = rec {
    nix = ["nixd" "alejandra" "statix" "deadnix"];
    shell = [
      "bash-language-server"
      "fish-lsp"
      "shellcheck"
      "shfmt"
      "tombi"
      "yaml-language-server"
      "vscode-json-language-server"
      "marksman"
      "prettierd"
    ];
    lua = ["lua" "lua-language-server" "stylua"];
    python = ["python3" "basedpyright-langserver" "ruff" "debugpy-adapter" "pytest"];
    rust = ["cargo" "rustc" "rust-analyzer" "rustfmt" "cargo-clippy" "lldb"];
    go = ["go" "gopls" "staticcheck" "dlv" "golangci-lint"];
    cpp = ["clang" "clangd" "gdb" "lldb" "cmake" "ninja" "make" "pkg-config"];
    jvm = ["java" "kotlin" "kotlin-lsp" "jdtls" "google-java-format"];
    node22 = [
      "node"
      "yarn"
      "tsc"
      "typescript-language-server"
      "eslint_d"
      "prettier"
      "prettierd"
      "vscode-json-language-server"
      "yaml-language-server"
      "tailwindcss-language-server"
      "graphql-lsp"
      "js-debug"
    ];
    node24 = commands.node22;
  };
  checkStack = name:
    pkgs.runCommand "devshell-${name}-inventory" {
      nativeBuildInputs = languageTooling.packagesFor [name];
    } ''
      missing=0
      ${pkgs.lib.concatMapStringsSep "\n" (command: ''
          if ! command -v ${pkgs.lib.escapeShellArg command} >/dev/null; then
            printf 'missing command in ${name} shell: %s\n' ${pkgs.lib.escapeShellArg command} >&2
            missing=1
          fi
        '')
        commands.${name}}
      test "$missing" -eq 0
      touch "$out"
    '';
in
  pkgs.runCommand "devshell-inventory" {} ''
    ${pkgs.lib.concatMapStringsSep "\n" (check: "test -e ${check}") (
      pkgs.lib.mapAttrsToList (name: _: checkStack name) commands
    )}
    touch "$out"
  ''
