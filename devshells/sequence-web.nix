args @ {
  perSystem,
  pkgs,
  ...
}:
((import ../lib args).languageTooling {inherit perSystem pkgs;}).mkShell {
  stacks = ["node22"];
  extraPackages = [pkgs.mkcert];
}
