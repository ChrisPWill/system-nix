# Shared by `nix fmt` (formatter.nix) and the formatting check so the two
# cannot disagree about which files are formatted, or how.
{
  projectRootFile = "flake.nix";

  programs = {
    alejandra.enable = true; # nix
    prettier.enable = true; # ts, tsx, json, md, scss, css, html, glsl
    stylua.enable = true; # lua
    shfmt.enable = true; # shell
    rustfmt.enable = true; # rust
    clang-format.enable = true; # cpp, h
    ktlint.enable = true; # kotlin
  };

  settings.global.excludes = [
    # Some of these fixtures intentionally have formatting issues
    "modules/home/dev/editors/neovim/tests/fixtures/**"
    "modules/home/dev/editors/neovim/tests/unit/fixtures/**"
  ];
}
