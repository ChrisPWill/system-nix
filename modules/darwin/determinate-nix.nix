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

    # With nix.enable off, nix-darwin never writes nix.conf, so the shared
    # binary caches would silently go unused. Determinate's nix.conf includes
    # this file for local additions.
    environment.etc."nix/nix.custom.conf" = {
      text = ''
        extra-substituters = ${lib.concatStringsSep " " config.nix.settings.substituters}
        extra-trusted-public-keys = ${lib.concatStringsSep " " config.nix.settings.trusted-public-keys}
      '';
      # The comment-only file the Determinate installer writes.
      knownSha256Hashes = ["3bd68ef979a42070a44f8d82c205cfd8e8cca425d91253ec2c10a88179bb34aa"];
    };
  };
}
