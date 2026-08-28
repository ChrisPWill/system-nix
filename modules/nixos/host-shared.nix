{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.self.nixosModules.nix-core
  ];

  environment.systemPackages =
    with pkgs; [
      btop
    ]
    # you can check if host is darwin by using pkgs.stdenv.hostPlatform.isDarwin
    #++ (pkgs.lib.optionals pkgs.stdenv.hostPlatform.isDarwin [pkgs.xbar])
    ;

  programs.zsh.enable = true;
  programs.fish.enable = true;
}
