{
  config,
  pkgs,
  ...
}: {
  # Shared skills are linked into ~/.claude/skills by ../shared-skills.nix.
  programs.claude-code = {
    enable = true;
    # nixpkgs' wrapper defaults CLAUDE_CODE_CERT_STORE to "system" (since
    # 2.1.308), but Claude Code's read of the macOS store can't build the chain
    # to api.anthropic.com, so every request fails with
    # UNABLE_TO_GET_ISSUER_CERT_LOCALLY. It's set in a wrapper rather than
    # home.sessionVariables because terminals started before a switch keep
    # __HM_SESS_VARS_SOURCED and never pick up new session variables.
    package = pkgs.symlinkJoin {
      name = "claude-code-${pkgs.claude-code.version}";
      paths = [pkgs.claude-code];
      nativeBuildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/claude --set CLAUDE_CODE_CERT_STORE bundled
      '';
      inherit (pkgs.claude-code) meta version;
    };

    rulesDir = config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/ai/shared-rules";

    lspServers = {
      nix = {
        command = "nixd";
        extensionToLanguage = {
          ".nix" = "nix";
        };
      };
      python = {
        command = "basedpyright-langserver";
        args = ["--stdio"];
        extensionToLanguage = {
          ".py" = "python";
        };
      };
      lua = {
        command = "lua-language-server";
        extensionToLanguage = {
          ".lua" = "lua";
        };
      };
      go = {
        command = "gopls";
        args = ["serve"];
        extensionToLanguage = {
          ".go" = "go";
        };
      };
      rust = {
        command = "rust-analyzer";
        extensionToLanguage = {
          ".rs" = "rust";
        };
      };
      typescript = {
        command = "typescript-language-server";
        args = ["--stdio"];
        extensionToLanguage = {
          ".js" = "javascript";
          ".jsx" = "javascriptreact";
          ".ts" = "typescript";
          ".tsx" = "typescriptreact";
        };
      };
      bash = {
        command = "bash-language-server";
        args = ["start"];
        extensionToLanguage = {
          ".sh" = "bash";
          ".bash" = "bash";
          ".zsh" = "bash";
        };
      };
      cpp = {
        command = "clangd";
        extensionToLanguage = {
          ".c" = "cpp";
          ".cpp" = "cpp";
          ".h" = "cpp";
          ".hpp" = "cpp";
        };
      };
      markdown = {
        command = "marksman";
        args = ["server"];
        extensionToLanguage = {
          ".md" = "markdown";
          ".mdx" = "markdown";
        };
      };
      yaml = {
        command = "yaml-language-server";
        args = ["--stdio"];
        extensionToLanguage = {
          ".yaml" = "yaml";
          ".yml" = "yaml";
        };
      };
      json = {
        command = "vscode-json-language-server";
        args = ["--stdio"];
        extensionToLanguage = {
          ".json" = "json";
          ".jsonc" = "json";
        };
      };
    };
  };
}
