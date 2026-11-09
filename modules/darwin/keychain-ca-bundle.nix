{
  config,
  lib,
  ...
}: {
  options.keychainCaBundle.enable = lib.mkEnableOption ''
    trusting the macOS keychain's certificates when Nix downloads sources for
    builds. Needed on a network that intercepts HTTPS, such as Zscaler
  '';

  config = lib.mkIf config.keychainCaBundle.enable {
    assertions = [
      {
        assertion = config.usesDeterminateNix;
        message = "keychainCaBundle relies on the keychain bundle Determinate Nix maintains.";
      }
    ];

    # Determinate Nix keeps /etc/nix/macos-keychain.crt up to date from the
    # keychain and uses it for the daemon's own downloads. Builds that fetch
    # sources, such as fetchgit, read NIX_SSL_CERT_FILE from their environment
    # instead and would otherwise fall back to Nix's public certificates.
    nix.settings.impure-env = "NIX_SSL_CERT_FILE=/etc/nix/macos-keychain.crt";
  };
}
