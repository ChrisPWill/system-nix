{
  inputs,
  config,
  lib,
  ...
}: let
  utils = inputs.nixCats.utils;
  mainNixCatsPackageName = "meow";
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
    programs.zsh.shellAliases."nvimconfig" = "(cd ${config.homeModuleDir}/nixCats; ${mainNixCatsPackageName} ./config/init.lua)";

    home.sessionVariables = {
      EDITOR = "meow";
      SUDO_EDITOR = "meow";
    };
    nixCats = {
      enable = true;

      # Adds plugins in inputs named "plugins-pluginName" to pkgs.neovimPlugins
      # Only applies to nixCats
      addOverlays = [(utils.standardPluginOverlay inputs)];

      # See packageDefinitions - says which one to install
      packageNames = [mainNixCatsPackageName];

      luaPath = config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/nixCats/config";

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
            lazygit
          ];
          lua = with pkgs; [
            lua-language-server
            stylua
          ];
          nix = with pkgs; [
            nixd
            alejandra
          ];
          node = with pkgs; [
            nodePackages.typescript-language-server
            prettierd
            eslint_d
            nodePackages.graphql-language-service-cli
            vscode-js-debug
          ];
          rust = with pkgs; [
            rust-analyzer
            rustfmt
            clippy
            tombi
          ];
          # go = with pkgs; [
          #   gopls
          #   delve
          #   golint
          #   golangci-lint
          #   gotools
          #   go-tools
          #   go
          # ];
        };

        # This is for plugins that will load at startup without using packadd:
        startupPlugins = {
          general = with pkgs.vimPlugins; [
            # lazy loading isnt required with a config this small
            # but as a demo, we do it anyway.
            lze
            lzextras
            snacks-nvim
            onedark-nvim
            vim-sleuth
            plenary-nvim
          ];
          rust = with pkgs.vimPlugins; [
            # Already lazy
            rustaceanvim
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
            mini-nvim
            nvim-lspconfig
            vim-startuptime
            blink-cmp
            nvim-treesitter.withAllGrammars
            nvim-treesitter-context
            lualine-nvim
            lualine-lsp-progress
            gitsigns-nvim
            which-key-nvim
            nvim-lint
            conform-nvim
            nvim-dap
            nvim-dap-ui
            nvim-dap-virtual-text
            markview-nvim
            neotest
            luasnip
            cmp_luasnip
            friendly-snippets
            nvim-scissors
            arrow-nvim
            leap-nvim
          ];
          copilot = with pkgs.vimPlugins; [
            copilot-lua
            copilot-lualine
            blink-copilot
          ];
          node = with pkgs.vimPlugins; [
            typescript-tools-nvim
            nvim-dap-vscode-js
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
        # These are the names of your packages
        # you can include as many as you wish.
        "${mainNixCatsPackageName}" = {pkgs, ...}: {
          # they contain a settings set defined above
          # see :help nixCats.flake.outputs.settings
          settings = {
            suffix-path = true;
            suffix-LD = true;
            wrapRc = true;
            # unwrappedCfgPath = "/path/to/here";
            # IMPORTANT:
            # your alias may not conflict with your other packages.
            aliases = ["nvim" "neovim" "nv"];
            # neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.neovim;
            hosts.python3.enable = true;
            hosts.node.enable = true;
          };
          # and a set of categories that you want
          # (and other information to pass to lua)
          # and a set of categories that you want
          categories = {
            general = true;
            lua = true;
            nix = true;
            node = true;
            rust = true;
            copilot = config.nixCats.custom.enableCopilot;

            # go = false;
          };
          # anything else to pass and grab in lua with `nixCats.extra`
          extra = {
            nixdExtras.nixpkgs = ''import ${pkgs.path} {}'';
          };
        };
      };
    };
  };
}
