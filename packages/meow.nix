{
  inputs,
  pkgs,
  ...
}: let
  neovimPackage = import ../modules/home/dev/editors/neovim/nixcats-package.nix {
    inherit inputs pkgs;
    lib = pkgs.lib;
    luaPath = ../modules/home/dev/editors/neovim/config;
    docsPath = ../modules/home/dev/editors/neovim/docs;
  };
in
  neovimPackage.meow
