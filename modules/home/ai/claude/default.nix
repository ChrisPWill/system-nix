{config, ...}: {
  programs.claude-code = {
    enable = true;

    rulesDir = config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/ai/claude/rules";

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
