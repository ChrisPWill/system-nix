{pkgs, ...}: {
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    substituters = [
      "https://niri.cachix.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
    ];
  };
  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  environment.systemPackages =
    with pkgs; [
      btop
    ]
    # you can check if host is darwin by using pkgs.stdenv.isDarwin
    #++ (pkgs.lib.optionals pkgs.stdenv.isDarwin [pkgs.xbar])
    ;

  programs.zsh.enable = true;
}
