{
  inputs,
  pkgs,
  ...
}:
(inputs.treefmt-nix.lib.evalModule pkgs {
  projectRootFile = "flake.nix";

  programs.alejandra.enable = true; # nix
  programs.prettier.enable = true; # ts, tsx, json, md, scss, css, html, glsl
  programs.stylua.enable = true; # lua
  programs.shfmt.enable = true; # shell
  # programs.taplo.enable = true; # toml
  programs.rustfmt.enable = true; # rust
  programs.clang-format.enable = true; # cpp, h
}).config.build.check
inputs.self
