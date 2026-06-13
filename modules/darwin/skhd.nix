{
  lib,
  pkgs,
  ...
}: let
  skhdStoreBinary = "${pkgs.skhd}/bin/skhd";
  skhdStableDir = "/Library/Application Support/Skhd";
  skhdStableBinary = "${skhdStableDir}/skhd";
in {
  config = lib.mkIf pkgs.stdenv.isDarwin {
    environment.systemPackages = [
      pkgs.skhd
    ];

    system.activationScripts.extraActivation.text = lib.mkAfter ''
      /bin/mkdir -p "${skhdStableDir}"
      /usr/sbin/chown root:wheel "${skhdStableDir}"
      /bin/chmod 0755 "${skhdStableDir}"

      if ! /usr/bin/cmp -s "${skhdStoreBinary}" "${skhdStableBinary}"; then
        /usr/bin/install -m 0555 -o root -g wheel "${skhdStoreBinary}" "${skhdStableBinary}.tmp"
        /bin/mv "${skhdStableBinary}.tmp" "${skhdStableBinary}"
      fi
    '';
  };
}
