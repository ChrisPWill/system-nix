{utils}: {pkgs, ...}: let
  keymap = utils.keymap;
  keymapRaw = utils.keymapRaw;
in {
  programs.nixvim = {
    extraPackages = with pkgs; [
      # language servers
      bash-language-server
      dockerfile-language-server
      lua-language-server
      nil
      # Temp removed https://github.com/NixOS/nixpkgs/issues/390063
      nodePackages.graphql-language-service-cli
      nodePackages.typescript-language-server
      rust-analyzer
      tailwindcss-language-server
      vscode-langservers-extracted

      # formatters
      prettierd
      stylua
      alejandra
    ];

    plugins.lsp = {
      enable = true;
      servers = {
        bashls.enable = true;
        dockerls.enable = true;
        graphql.enable = true;
        graphql.package = null;
        html.enable = true;
        jsonls.enable = true;
        lua_ls.enable = true;
        nil_ls.enable = true;
        nil_ls.settings.formatting.command = ["alejandra"];
        nushell.enable = true;
        rust_analyzer = {
          enable = true;
          installCargo = false;
          installRustc = false;
        };
        tailwindcss.enable = true;
        terraformls.enable = true;
        ts_ls = {
          enable = true;
          settings = {
            maxTsServerMemory = 8192;
          };
        };
        vimls.enable = true;
        yamlls.enable = true;
      };
    };

    # Formatter
    plugins.conform-nvim = let
      prettierDefault = {
        __unkeyed-1 = "prettierd";
        __unkeyed-2 = "prettier";
        timeout_ms = 2000;
        stop_after_first = true;
      };
    in {
      enable = true;
      settings = {
        format_on_save = ''
          function(bufnr)
            -- Disable with a global or buffer-local variable
            if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
              return
            end
            return { timeout_ms = 500, lsp_format = "fallback" }
          end
        '';
        formatters_by_ft = {
          # prettier
          javascript = prettierDefault;
          javascriptreact = prettierDefault;
          typescript = prettierDefault;
          typescriptreact = prettierDefault;
          css = prettierDefault;
          html = prettierDefault;
          json = prettierDefault;
          yaml = prettierDefault;
          markdown = prettierDefault;
          graphql = prettierDefault;
          "markdown.mdx" = prettierDefault;

          rust = ["rustfmt"];

          nix = ["alejandra"];

          lua = ["stylua"];
        };
      };
    };

    userCommands = {
      FormatEnable = {
        bang = true;
        command.__raw = ''
          function(args)
            if args.bang then
              vim.b.disable_autoformat = false
            else
              vim.g.disable_autoformat = false
            end
          end
        '';
      };
      FormatDisable = {
        bang = true;
        command.__raw = ''
          function(args)
            if args.bang then
              vim.b.disable_autoformat = true
            else
              vim.g.disable_autoformat = true
            end
          end
        '';
      };
    };

    keymaps = [
      (keymap "<A-]>" "<C-I>" "Go to newer jump" {})
      (keymap "<A-[>" "<C-O>" "Go to older jump" {})

      # LSP specific
      (keymapRaw "KK" "vim.lsp.buf.hover" "Show LSP info" {})
      (keymapRaw "KA" "vim.lsp.buf.code_action" "LSP Code Action" {})
      (keymapRaw "KE" "vim.lsp.buf.rename" "LSP Rename" {})
      (keymapRaw "KD" "vim.lsp.buf.definition" "LSP Open Definition" {})
      (keymapRaw "KI" "vim.lsp.buf.implementation" "LSP Open Implementations" {})
      (keymapRaw "KN" "vim.diagnostic.goto_next" "LSP Goto next diagnostic" {})
      (keymapRaw "KP" "vim.diagnostic.goto_prev" "LSP Goto prev diagnostic" {})
      (keymapRaw "KR" "require('telescope.builtin').lsp_references" "Show LSP References" {})
      (keymap "KT" "<cmd>Telescope diagnostics<cr>" "Show LSP Diagnostics" {})
      (keymapRaw "KF" "function() require('conform').format({ async = true, timeout_ms = 10000 }) end" "LSP Format" {})
    ];
  };
}
