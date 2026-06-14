{
  inputs,
  pkgs,
  ...
}:
(inputs.treefmt-nix.lib.evalModule pkgs {
  projectRootFile = "flake.nix";

  programs = {
    alejandra.enable = true; # nix
    prettier.enable = true; # ts, tsx, json, md, scss, css, html, glsl
    stylua.enable = true; # lua
    shfmt.enable = true; # shell
    # taplo.enable = true; # toml
    rustfmt.enable = true; # rust
    clang-format.enable = true; # cpp, h
  };
}).config.build.check
inputs.self
