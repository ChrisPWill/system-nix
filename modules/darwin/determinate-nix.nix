{
  config,
  lib,
  pkgs,
  ...
}: {
  options.usesDeterminateNix = lib.mkEnableOption "Determinate Nix compatibility";

  config = lib.mkIf config.usesDeterminateNix {
    # Determinate owns the Nix installation and daemon, so nix-darwin must not
    # try to manage them independently.
    nix = {
      enable = false;
      gc.automatic = lib.mkForce false;
      optimise.automatic = lib.mkForce false;
      package = pkgs.nix;
    };
  };
}
