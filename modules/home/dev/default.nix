{...}: {
  imports = [
    ./editors/cursor.nix
    ./editors/neovim
    ./editors/helix
    ./multiplexer
    ./vcs/version-control.nix
    ./nix.nix
    ./node.nix
    ./utils.nix
  ];
}
