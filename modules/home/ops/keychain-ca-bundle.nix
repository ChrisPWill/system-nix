{
  config,
  lib,
  pkgs,
  ...
}: let
  bundle = "${config.xdg.dataHome}/ca-certificates/keychain.pem";
in {
  options.ops.keychainCaBundle.enable = lib.mkEnableOption ''
    trusting the macOS keychain's certificates in tools from Nix. Needed on a
    network that intercepts HTTPS, such as Zscaler, whose root certificate is
    installed only in the keychain. The Nix daemon needs the same fix
    separately; see modules/darwin/keychain-ca-bundle.nix
  '';

  config = lib.mkIf (config.ops.keychainCaBundle.enable && pkgs.stdenv.hostPlatform.isDarwin) {
    # Exported on every switch, so a rotated root certificate is picked up.
    home.activation.exportKeychainCaBundle = lib.hm.dag.entryAfter ["writeBoundary"] ''
      run ${../../../scripts/export-keychain-ca-bundle} ${lib.escapeShellArg bundle} \
        || warnEcho "Could not export keychain certificates; HTTPS through the corporate proxy may fail."
    '';

    # Downloads the nix command makes itself, such as flake inputs.
    nix.settings.ssl-cert-file = bundle;

    home.sessionVariables = {
      # nixpkgs' OpenSSL reads this, so it covers git, curl and others from Nix.
      NIX_SSL_CERT_FILE = bundle;
      # Go programs such as gh, and Python's ssl module.
      SSL_CERT_FILE = bundle;
      # Python's requests library ignores SSL_CERT_FILE.
      REQUESTS_CA_BUNDLE = bundle;
      # Node, including npm and pnpm installed through mise.
      NODE_EXTRA_CA_CERTS = bundle;
    };
  };
}
