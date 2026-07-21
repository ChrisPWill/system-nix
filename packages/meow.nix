{
  inputs,
  perSystem,
  pkgs,
  ...
}: let
  neovimPackage = import ../modules/home/dev/editors/neovim/nixcats-package.nix {
    inherit inputs pkgs;
    inherit (pkgs) lib;
    luaPath = ../modules/home/dev/editors/neovim/config;
    docsPath = ../modules/home/dev/editors/neovim/docs;
    kotlinLsp = perSystem.self.kotlin-lsp;
  };
in
  neovimPackage.meow
