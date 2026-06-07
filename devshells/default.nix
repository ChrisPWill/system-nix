{
  inputs,
  pkgs,
  ...
}:
pkgs.mkShell {
  packages = with pkgs; [
    typescript
    nodejs_latest
    watchexec
    qemu
    qemu-utils
  ];
}
