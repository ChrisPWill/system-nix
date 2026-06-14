{...}: {
  imports = [
    ./editors/cursor.nix
    ./editors/neovim
    ./editors/helix
    ./infrastructure.nix
    ./multiplexer
    ./python.nix
    ./vcs/version-control.nix
    ./nix.nix
    ./utils.nix
  ];
}
