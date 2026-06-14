{
  inputs,
  pkgs,
  ...
}:
pkgs.runCommandLocal "deadnix-check" {
  nativeBuildInputs = [pkgs.deadnix];
} ''
  deadnix --fail ${inputs.self}
  touch $out
''
