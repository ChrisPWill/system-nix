{
  inputs,
  pkgs,
  ...
}:
(inputs.treefmt-nix.lib.evalModule pkgs {
  projectRootFile = "flake.nix";

  # Note: treefmt-nix can also be configured here directly
  # But we'll use the toml file we just created.
  # If we want to add the binaries to pkgs, we can do it here.

  programs = {
    alejandra.enable = true; # nix
    prettier.enable = true; # ts, tsx, json, md, scss, css, html, glsl
    stylua.enable = true; # lua
    shfmt.enable = true; # shell
    # tombi.enable = true; # toml
    rustfmt.enable = true; # rust
    clang-format.enable = true; # cpp, h
    ktlint.enable = true; # kotlin
  };

  settings.global.excludes = [
    "modules/home/dev/editors/neovim/tests/fixtures/**"
  ];
}).config.build.wrapper
