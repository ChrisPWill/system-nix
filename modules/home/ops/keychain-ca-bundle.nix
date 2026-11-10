{
  config,
  lib,
  pkgs,
  ...
}: let
  # Determinate Nix keeps this up to date from the macOS keychain.
  bundle = "/etc/nix/macos-keychain.crt";
in {
  options.ops.keychainCaBundle.enable = lib.mkEnableOption ''
    trusting the macOS keychain's certificates in tools from Nix. Needed on a
    network that intercepts HTTPS, such as Zscaler, whose root certificate is
    installed only in the keychain. Builds need the same fix in the Nix
    daemon; see modules/darwin/keychain-ca-bundle.nix
  '';

  config = lib.mkIf (config.ops.keychainCaBundle.enable && pkgs.stdenv.hostPlatform.isDarwin) {
    assertions = [
      {
        assertion = config.usesDeterminateNix;
        message = "ops.keychainCaBundle relies on the keychain bundle Determinate Nix maintains.";
      }
    ];

    # In git's config rather than GIT_SSL_CAINFO, because Homebrew clears the
    # environment before it runs git to clone taps.
    programs.git.settings.http.sslCAInfo = bundle;

    # The JVM ignores the variables below and can't read a PEM bundle as a
    # trust store, so Gradle reads the keychain directly. NONE stops the JVM
    # opening its cacerts file as a keychain. The wrapper reads these too, so
    # Gradle distribution downloads work.
    home.file.".gradle/gradle.properties".text = ''
      systemProp.javax.net.ssl.trustStore=NONE
      systemProp.javax.net.ssl.trustStoreType=KeychainStore
    '';

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
