{
  pkgs,
  lib,
  config,
  ...
}: {
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
    nodePackages.typescript-language-server
    prettierd
    nodePackages.vscode-langservers-extracted # HTML/CSS/JSON
    nodePackages.yaml-language-server

    # Shell
    nodePackages.bash-language-server
    shellcheck
    shfmt
    fish-lsp

    # Markdown
    marksman
  ];

  stylix.targets.helix.enable = false;

  programs.helix = {
    enable = true;

    # Using onedark to match Neovim's onedark-nvim
    settings = {
      theme = "onedark";
      editor = {
        line-number = "relative";
        cursorline = true;
        color-modes = true;
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        lsp = {
          display-messages = true;
          display-inlay-hints = true;
        };
        indent-guides = {
          render = true;
          character = "╎";
        };
        soft-wrap.enable = true;
        statusline = {
          left = ["mode" "spinner"];
          center = ["file-name"];
          right = ["diagnostics" "selections" "position" "file-encoding" "file-line-ending" "file-type"];
          separator = "│";
          mode.normal = "NORMAL";
          mode.insert = "INSERT";
          mode.select = "SELECT";
        };
      };

      # Hybrid Philosophy - Helix-aligned keymaps in Neovim means we don't need much here
      # but we can ensure some Neovim-like comfort
      keys.normal = {
        "esc" = ["collapse_selection" "keep_primary_selection"];
      };
    };

    languages = {
      language = [
        {
          name = "nix";
          auto-format = true;
          formatter = {
            command = "alejandra";
          };
          language-servers = ["nixd"];
        }
        {
          name = "python";
          auto-format = true;
          language-servers = ["basedpyright" "ruff"];
          formatter = {
            command = "ruff";
            args = ["format" "-"];
          };
        }
        {
          name = "rust";
          auto-format = true;
          language-servers = ["rust-analyzer"];
        }
        {
          name = "go";
          auto-format = true;
          language-servers = ["gopls"];
        }
        {
          name = "lua";
          auto-format = true;
          language-servers = ["lua-language-server"];
          formatter = {
            command = "stylua";
            args = ["-"];
          };
        }
        {
          name = "javascript";
          auto-format = true;
          language-servers = ["typescript-language-server"];
          formatter = {
            command = "prettierd";
            args = ["--stdin-filepath" "file.js"];
          };
        }
        {
          name = "typescript";
          auto-format = true;
          language-servers = ["typescript-language-server"];
          formatter = {
            command = "prettierd";
            args = ["--stdin-filepath" "file.ts"];
          };
        }
        {
          name = "markdown";
          auto-format = true;
          language-servers = ["marksman"];
        }
        {
          name = "bash";
          auto-format = true;
          language-servers = ["bash-language-server"];
          formatter = {
            command = "shfmt";
            args = ["-i" "2"];
          };
        }
        {
          name = "fish";
          auto-format = true;
          language-servers = ["fish-lsp"];
        }
      ];

      language-server = {
        nixd = {
          command = "nixd";
          config = {
            nixpkgs = {
              expr = "import <nixpkgs> {}";
            };
          };
        };
        basedpyright = {
          command = "basedpyright-langserver";
          args = ["--stdio"];
        };
        ruff = {
          command = "ruff";
          args = ["server"];
        };
        rust-analyzer = {
          command = "rust-analyzer";
        };
        gopls = {
          command = "gopls";
        };
        "lua-language-server" = {
          command = "lua-language-server";
        };
        "typescript-language-server" = {
          command = "typescript-language-server";
          args = ["--stdio"];
        };
        marksman = {
          command = "marksman";
          args = ["server"];
        };
        "bash-language-server" = {
          command = "bash-language-server";
          args = ["start"];
        };
        "fish-lsp" = {
          command = "fish-lsp";
          args = ["start"];
        };
      };
    };
  };
}
