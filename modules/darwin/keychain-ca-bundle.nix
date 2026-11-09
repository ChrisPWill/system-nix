{
  config,
  lib,
  ...
}: let
  # Also the path the one-time manual fix in
  # hosts/cwilliams-intuit-laptop/README.md uses, so nix-darwin takes over the
  # same file.
  bundle = "/etc/nix/ca-bundle.pem";
in {
  options.keychainCaBundle.enable = lib.mkEnableOption ''
    trusting the macOS keychain's certificates in the Nix daemon. Needed on a
    network that intercepts HTTPS, such as Zscaler: the daemon downloads
    sources for builds and doesn't read the keychain
  '';

  config = lib.mkIf config.keychainCaBundle.enable {
    # Exported on every switch, so a rotated root certificate is picked up.
    system.activationScripts.extraActivation.text = lib.mkAfter ''
      /bin/bash ${../../scripts/export-keychain-ca-bundle} ${bundle} \
        || echo "warning: could not export keychain certificates for the Nix daemon" >&2
    '';

    nix.settings.ssl-cert-file = bundle;
  };
}
