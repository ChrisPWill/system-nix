args @ {
  perSystem,
  pkgs,
  ...
}:
((import ../lib args).languageTooling {inherit perSystem pkgs;}).mkShell {
  stacks = ["node22"];
  shellHook = ''
    export PS1="(node22) $PS1"
  '';
}
