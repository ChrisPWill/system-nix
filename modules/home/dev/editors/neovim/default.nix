{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: let
  utils = inputs.nixCats.utils;
  mainNixCatsPackageName = "meow";

  commonSettings = {
    suffix-path = true;
    suffix-LD = true;
    wrapRc = true;
    hosts.python3.enable = true;
    hosts.node.enable = true;
  };

  commonCategories = {
    general = true;
    lua = true;
    nix = true;
    node = true;
    rust = true;
    cpp = true;
    python = true;
    go = true;
    web = true;
    java = true;
    kotlin = true;
    copilot = config.nixCats.custom.enableCopilot;
  };

  commonExtra = {
    nixdExtras.nixpkgs = "import ${pkgs.path} {}";
    docsPath = "${config.homeModuleDir}/dev/editors/neovim/docs";
  };
in {
  imports = [
    inputs.nixCats.homeModule
  ];

  options = {
    nixCats.custom = {
      enableCopilot = lib.mkEnableOption "Enable Copilot in Neovim (nixCats)";
    };
  };

  config = {
    # Easy config editing alias
    programs.zsh.shellAliases."nvimconfig" = "(cd ${config.homeModuleDir}/dev/editors/neovim; ${mainNixCatsPackageName} ./config/init.lua)";

    home.sessionVariables = {
      EDITOR = "meow";
      SUDO_EDITOR = "meow";
    };

    home.file."${config.xdg.configHome}/nvim/docs".source = config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/dev/editors/neovim/docs";

    nixCats = {
      enable = true;

      # Adds plugins in inputs named "plugins-pluginName" to pkgs.neovimPlugins
      # Only applies to nixCats
      addOverlays = [(utils.standardPluginOverlay inputs)];

      # See packageDefinitions - says which one to install
      packageNames = [mainNixCatsPackageName] ++ pkgs.lib.optionals config.isPersonalMachine ["leet" "nvim-gemini"];

      luaPath = config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/dev/editors/neovim/config";

      # the .replace vs .merge options are for modules based on existing configurations,
      # they refer to how multiple categoryDefinitions get merged together by the module.
      # for useage of this section, refer to :h nixCats.flake.outputs.categories
      categoryDefinitions.replace = {
        pkgs,
        # settings,
        # categories,
        # extra,
        # name,
        # mkPlugin,
        ...
      }: {
        # to define and use a new category, simply add a new list to a set here,
        # and later, you will include categoryname = true; in the set you
        # provide when you build the package using this builder function.
        # see :help nixCats.flake.outputs.packageDefinitions for info on that section.

        # lspsAndRuntimeDeps:
        # this section is for dependencies that should be available
        # at RUN TIME for plugins. Will be available to PATH within neovim terminal
        # this includes LSPs
        lspsAndRuntimeDeps = {
          general = with pkgs; [
            ast-grep
            bash-language-server
            fd
            fish-lsp
            koji # conventional commit editor
            lazygit
            marksman
            prettierd
            ripgrep
            shellcheck
            shfmt
            silicon # take code screenshots
            tombi
            tree-sitter
            treefmt
          ];
          lua = with pkgs; [
            lua-language-server
            stylua
          ];
          nix = with pkgs; [
            alejandra
            nixd
          ];
          node = with pkgs; [
            eslint_d
            graphql-language-service-cli
            prettier
            typescript-language-server
            vscode-js-debug
          ];
          rust = with pkgs; [
            clippy
            lldb
            rust-analyzer
            rustfmt
          ];
          cpp = with pkgs; [
            clang-tools
            gdb
            lldb
          ];
          python = with pkgs; [
            basedpyright
            python3Packages.debugpy
            ruff
          ];
          go = with pkgs; [
            delve
            go
            go-tools
            golangci-lint
            gopls
            gotools
          ];
          java = with pkgs; [
            google-java-format
            jdt-language-server
          ];
          kotlin = with pkgs; [
            kotlin-language-server
            ktlint
          ];
          web = with pkgs; [
            tailwindcss
            vscode-langservers-extracted
            yaml-language-server
          ];
        };

        # This is for plugins that will load at startup without using packadd:
        startupPlugins = {
          general = with pkgs.vimPlugins; [
            lze
            lzextras
            nui-nvim
            nvim-navic
            nvim-nio
            nvim-notify
            nvim-treesitter.withAllGrammars
            onedark-nvim
            plenary-nvim
            snacks-nvim
            vim-sleuth
          ];
          rust = with pkgs.vimPlugins; [
            rustaceanvim
          ];
          java = with pkgs.vimPlugins; [
            nvim-jdtls
          ];
          leet = with pkgs.vimPlugins; [
            leetcode-nvim
            nui-nvim
          ];
        };

        # not loaded automatically at startup.
        # use with packadd and an autocommand in config to achieve lazy loading
        optionalPlugins = {
          go = with pkgs.vimPlugins; [
            nvim-dap-go
          ];
          lua = with pkgs.vimPlugins; [
            lazydev-nvim
          ];
          general = with pkgs.vimPlugins; [
            (pkgs.neovimUtils.grammarToPlugin (pkgs.tree-sitter-grammars.tree-sitter-nu.overrideAttrs (p: {installQueries = true;})))
            actions-preview-nvim
            arrow-nvim
            blink-cmp
            blink-compat
            cmp_luasnip
            conform-nvim
            friendly-snippets
            gitsigns-nvim
            grug-far-nvim
            inc-rename-nvim
            leap-nvim
            lualine-lsp-progress
            lualine-nvim
            luasnip
            markview-nvim
            mini-nvim
            neotest
            noice-nvim
            nvim-dap
            nvim-dap-ui
            nvim-dap-virtual-text
            nvim-highlight-colors
            nvim-lint
            nvim-lspconfig
            nvim-scissors
            nvim-treesitter-context
            nvim-treesitter-parsers.jinja # Useful for nunjucks too
            nvim-treesitter-parsers.jinja_inline # Useful for nunjucks too
            nvim-treesitter-textobjects
            treewalker-nvim
            trouble-nvim
            vim-startuptime
            which-key-nvim
          ];
          node = with pkgs.vimPlugins; [
            neotest-deno
            neotest-jest
            nvim-dap-vscode-js
            typescript-tools-nvim
          ];
          cpp = with pkgs.vimPlugins; [
            neotest-ctest
          ];
          copilot = with pkgs.vimPlugins; [
            blink-copilot
            copilot-lua
            copilot-lualine
          ];
          python = with pkgs.vimPlugins; [
            neotest-python
            nvim-dap-python
          ];
          local-llm = with pkgs.vimPlugins; [
            avante-nvim
            dressing-nvim
            minuet-ai-nvim
            nui-nvim
            render-markdown-nvim
          ];
          gemini = with pkgs.vimPlugins; [
            avante-nvim
            minuet-ai-nvim
            dressing-nvim
            nui-nvim
            render-markdown-nvim
          ];
        };

        # shared libraries to be added to LD_LIBRARY_PATH
        # variable available to nvim runtime
        sharedLibraries = {
          general = [];
        };

        # environmentVariables:
        # this section is for environmentVariables that should be available
        # at RUN TIME for plugins. Will be available to path within neovim terminal
        environmentVariables = {
          # test = {
          #   CATTESTVAR = "It worked!";
          # };
        };

        # categories of the function you would have passed to withPackages
        python3.libraries = {
          # test = [ (_:[]) ];
        };

        # If you know what these are, you can provide custom ones by category here.
        # If you dont, check this link out:
        # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/setup-hooks/make-wrapper.sh
        extraWrapperArgs = {
          # test = [
          #   '' --set CATTESTVAR2 "It worked again!"''
          # ];
        };
      };

      # see :help nixCats.flake.outputs.packageDefinitions
      packageDefinitions.replace = {
        "${mainNixCatsPackageName}" = {pkgs, ...}: {
          settings =
            commonSettings
            // {
              aliases = ["nvim" "neovim" "nv"];
            };
          categories =
            commonCategories
            // {
              local-llm = false;
            };
          extra = commonExtra;
        };

        "nvim-llm" = {pkgs, ...}: {
          settings =
            commonSettings
            // {
              aliases = ["nvim" "neovim" "nv"];
            };
          categories =
            commonCategories
            // {
              local-llm = config.services.local-ollama.enable;
            };
          extra = commonExtra;
        };

        "nvim-gemini" = {pkgs, ...}: {
          settings =
            commonSettings
            // {
              aliases = ["nvg"];
            };
          categories =
            commonCategories
            // {
              gemini = true;
            };
          extra = commonExtra;
        };

        "leet" = {pkgs, ...}: {
          settings = commonSettings;
          categories = {
            general = true;
            leet = true;
            python = true;
          };
          extra = commonExtra;
        };
      };
    };
  };
}
