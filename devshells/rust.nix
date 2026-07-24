args @ {
  perSystem,
  pkgs,
  ...
}:
((import ../lib args).languageTooling {inherit perSystem pkgs;}).mkShell {
  stacks = ["rust"];
}
