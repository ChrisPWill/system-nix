{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.self.nixosModules.nix-core
    inputs.self.modules.shared.approved-apps
  ];

  environment.systemPackages =
    config.filterApproved {
      inherit (pkgs) btop;
    }
    # you can check if host is darwin by using pkgs.stdenv.hostPlatform.isDarwin
    #++ (pkgs.lib.optionals pkgs.stdenv.hostPlatform.isDarwin [pkgs.xbar])
    ;

  # macOS ships zsh, and NixOS needs a login shell, so zsh isn't gated here.
  programs.zsh.enable = true;
  programs.fish.enable = config.appApproved.fish;
}
