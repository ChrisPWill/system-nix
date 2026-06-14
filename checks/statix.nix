{
  inputs,
  pkgs,
  ...
}:
pkgs.runCommandLocal "statix-check" {
  nativeBuildInputs = [pkgs.statix];
} ''
  statix check ${inputs.self}
  touch $out
''
