{...}: {
  imports = [
    ./editors/neovim
    ./editors/helix
    ./terminal/zellij
    ./terminal/wezterm
    ./vcs/version-control.nix
    ./utils.nix
  ];
}
