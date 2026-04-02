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

  programs.alejandra.enable = true; # nix
  programs.prettier.enable = true; # ts, tsx, json, md, scss, css, html, glsl
  programs.stylua.enable = true; # lua
  programs.shfmt.enable = true; # shell
  programs.taplo.enable = true; # toml
  programs.rustfmt.enable = true; # rust
  programs.clang-format.enable = true; # cpp, h
}).config.build.wrapper
