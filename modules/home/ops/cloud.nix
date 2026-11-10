{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = lib.optionals config.appApproved.google-cloud-sdk [
    # nixpkgs builds gcloud on Python 3.14. Since 3.13 Python verifies
    # certificates strictly, and rejects Zscaler's root for a Basic
    # Constraints extension not marked critical, even though the keychain
    # bundle trusts it (see keychain-ca-bundle.nix). Python 3.12 does not
    # apply that check, so pin gcloud to it until the proxy's root is fixed.
    (pkgs.google-cloud-sdk.override {python314 = pkgs.python312;})
  ];
}
