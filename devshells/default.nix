{
  inputs,
  pkgs,
  system,
  ...
}:
pkgs.mkShell {
  buildInputs = [
    # For AGS (graphical env) on Linux
    inputs.ags.packages.${system}.default
  ];

  packages = with pkgs; [
    typescript
    nodejs_latest
  ];
}
