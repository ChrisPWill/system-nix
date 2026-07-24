{...}: {
  imports = [
    ./editors/neovim
    ./editors/helix
    ./envoluntary
    ./multiplexer
    ./vcs/version-control.nix
    ./mise.nix
    ./nix.nix
    ./utils.nix
  ];
}
