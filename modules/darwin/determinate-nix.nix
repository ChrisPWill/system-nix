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
      text =
        ''
          extra-substituters = ${lib.concatStringsSep " " config.nix.settings.substituters}
          extra-trusted-public-keys = ${lib.concatStringsSep " " config.nix.settings.trusted-public-keys}
        ''
        + lib.optionalString (config.nix.settings ? ssl-cert-file) ''
          ssl-cert-file = ${config.nix.settings.ssl-cert-file}
        '';
      knownSha256Hashes = [
        # The comment-only file the Determinate installer writes.
        "3bd68ef979a42070a44f8d82c205cfd8e8cca425d91253ec2c10a88179bb34aa"
        # The one-line file from the manual certificate fix in
        # hosts/cwilliams-intuit-laptop/README.md.
        "9a161a75fa3ec3268115b25f9de59fc46050c28afb8bc0ff0892f5c5e05bc39d"
      ];
    };
  };
}
