{
  inputs,
  lib ? pkgs.lib,
  pkgs,
  luaPath,
  docsPath,
  enableCopilot ? false,
  enableLocalOllama ? false,
  neovimProvider ? null,
  geminiApiKeyPath ? null,
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
    copilot = enableCopilot;
  };

  commonExtra = {
    nixdExtras.nixpkgs = "import ${pkgs.path} {}";
    inherit docsPath;
  };

  aiWrapperArgs = lib.optionalAttrs (geminiApiKeyPath != null) {
    gemini = [
      "--run"
      " 'test -f ${geminiApiKeyPath} && export GEMINI_API_KEY=$(cat ${geminiApiKeyPath})' "
    ];
    antigravity = [
      "--run"
      " 'test -f ${geminiApiKeyPath} && export GEMINI_API_KEY=$(cat ${geminiApiKeyPath})' "
    ];
  };

  dependencyOverlays = [(utils.standardPluginOverlay inputs)];

  categoryDefinitions = {pkgs, ...}: {
    lspsAndRuntimeDeps = {
      general = with pkgs; [
        ast-grep
        bash-language-server
        fd
        fish-lsp
        koji
        lazygit
        marksman
        prettierd
        ripgrep
        shellcheck
        shfmt
        silicon
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
        typescript
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

    optionalPlugins = {
      go = with pkgs.vimPlugins; [
        nvim-dap-go
      ];
      lua = with pkgs.vimPlugins; [
        lazydev-nvim
      ];
      general = with pkgs.vimPlugins; [
        (pkgs.neovimUtils.grammarToPlugin (pkgs.tree-sitter-grammars.tree-sitter-nu.overrideAttrs (_: {installQueries = true;})))
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
        nvim-treesitter-parsers.jinja
        nvim-treesitter-parsers.jinja_inline
        nvim-treesitter-textobjects
        treewalker-nvim
        trouble-nvim
        vim-startuptime
        which-key-nvim
      ];
      java = with pkgs.vimPlugins; [
        neotest-java
      ];
      kotlin = with pkgs.vimPlugins; [
        pkgs.neovimPlugins.neotest-kotlin
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
      ai = with pkgs.vimPlugins; [
        avante-nvim
        minuet-ai-nvim
        dressing-nvim
        nui-nvim
        render-markdown-nvim
      ];
    };

    sharedLibraries = {
      general = [];
    };

    environmentVariables = {};

    python3.libraries = {};

    extraWrapperArgs = aiWrapperArgs;
  };

  packageDefinitions = {
    "${mainNixCatsPackageName}" = _: {
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

    "nvim-llm" = _: {
      settings =
        commonSettings
        // {
          aliases = ["nvl"];
        };
      categories =
        commonCategories
        // {
          local-llm = enableLocalOllama;
        };
      extra = commonExtra;
    };

    "nvim-ai" = _: {
      settings =
        commonSettings
        // {
          aliases = ["nva"];
        };
      categories =
        commonCategories
        // {
          ai = neovimProvider == "gemini" || neovimProvider == "antigravity";
          local-llm = neovimProvider == "ollama" && enableLocalOllama;
          gemini = neovimProvider == "gemini";
          antigravity = neovimProvider == "antigravity";
        };
      extra = commonExtra;
    };

    "leet" = _: {
      settings = commonSettings;
      categories = {
        general = true;
        leet = true;
        python = true;
      };
      extra = commonExtra;
    };
  };

  buildPackage = name:
    utils.baseBuilder luaPath {
      inherit pkgs dependencyOverlays;
    }
    categoryDefinitions
    packageDefinitions
    name;
in {
  inherit
    mainNixCatsPackageName
    dependencyOverlays
    categoryDefinitions
    packageDefinitions
    buildPackage
    ;

  meow = buildPackage mainNixCatsPackageName;
}
