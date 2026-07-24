{...}: {
  imports = [
    ./editors/neovim
    ./editors/helix
    ./multiplexer
    ./vcs/version-control.nix
    ./mise.nix
    ./nix.nix
    ./node.nix
    ./utils.nix
  ];
}
