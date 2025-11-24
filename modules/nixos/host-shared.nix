{pkgs, ...}: {
  nix.settings.experimental-features = ["nix-command" "flakes"];

  environment.systemPackages = with pkgs;
    [
      btop
    ]
    # you can check if host is darwin by using pkgs.stdenv.isDarwin
    #++ (pkgs.lib.optionals pkgs.stdenv.isDarwin [pkgs.xbar])
    ;

  programs.zsh.enable = true;

  users.defaultUserShell = pkgs.zsh;
}
