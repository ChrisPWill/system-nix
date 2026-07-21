{
  config,
  lib,
  pkgs,
  ...
}: let
  kanataConfig = pkgs.writeText "kanata-global-leader.kbd" ''
    (defcfg
      ${config.kanata.globalLeader.defcfg}
    )

    ${config.kanata.globalLeader.config}
  '';
  karabinerVirtualHid = rec {
    version = "6.2.0";
    rev = "c7df2059a84162d3d2d6784bebc887e888059375";
    receipt = "org.pqrs.Karabiner-DriverKit-VirtualHIDDevice";
    pkg = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice/${rev}/dist/Karabiner-DriverKit-VirtualHIDDevice-${version}.pkg";
      hash = "sha256-noxGI58HSBYSQeQkRIV5ASJOXIL1tYoXMd9McL8HNqg=";
    };
    daemonPath = "/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon";
    managerPath = "/Applications/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager";
  };
  kanataStoreBinary = "${pkgs.kanata}/bin/kanata";
  kanataStableDir = "/Library/Application Support/Kanata";
  kanataStableBinary = "${kanataStableDir}/kanata";
  kanataSourceMarker = "${kanataStableDir}/.source-store-path";
  # kanata ships ad-hoc signed, which macOS TCC keys Input Monitoring grants to by raw
  # binary hash (cdhash). Every nixpkgs version bump silently invalidates the grant even
  # though it still shows enabled in System Settings. Re-signing with a persistent local
  # certificate gives TCC a stable identity to key off instead, so grants survive rebuilds.
  kanataCertCommonName = "org.nixos.kanata-codesign";
  kanataCodesignIdentifier = "org.nixos.kanata";
  kanataCommandArgs =
    [
      kanataStableBinary
      "--cfg"
      "${kanataConfig}"
    ]
    ++ config.kanata.globalLeader.extraArgs;
in {
  config = lib.mkIf pkgs.stdenv.isDarwin {
    # macOS normally translates the physical F-row into consumer/media events.
    # Kanata intercepts the underlying F1-F12 events before that translation, so
    # reproduce it in the Kanata layer and use Fn to access real function keys.
    kanata.globalLeader.functionRowMode = lib.mkDefault "macos-media";

    environment.systemPackages = [
      pkgs.kanata
    ];

    system.activationScripts.extraActivation.text = lib.mkAfter ''
      /bin/mkdir -p "${kanataStableDir}"
      /usr/sbin/chown root:wheel "${kanataStableDir}"
      /bin/chmod 0755 "${kanataStableDir}"

      if ! /usr/bin/security find-certificate -c "${kanataCertCommonName}" /Library/Keychains/System.keychain >/dev/null 2>&1; then
        echo "generating self-signed code-signing certificate for kanata..." >&2
        kanataCertTmp="$(/usr/bin/mktemp -d)"
        ${pkgs.openssl}/bin/openssl req -x509 -newkey rsa:2048 \
          -keyout "$kanataCertTmp/key.pem" -out "$kanataCertTmp/cert.pem" \
          -days 36500 -nodes -subj "/CN=${kanataCertCommonName}" \
          -addext "keyUsage=critical,digitalSignature" \
          -addext "extendedKeyUsage=codeSigning" \
          -addext "basicConstraints=critical,CA:false"
        ${pkgs.openssl}/bin/openssl pkcs12 -export -legacy \
          -out "$kanataCertTmp/cert.p12" \
          -inkey "$kanataCertTmp/key.pem" -in "$kanataCertTmp/cert.pem" \
          -keypbe PBE-SHA1-3DES -certpbe PBE-SHA1-3DES -macalg sha1 \
          -passout pass:kanata-codesign-transient
        /usr/bin/security import "$kanataCertTmp/cert.p12" -k /Library/Keychains/System.keychain \
          -P kanata-codesign-transient -T /usr/bin/codesign -T /usr/bin/security
        /usr/bin/security add-trusted-cert -d -r trustRoot -p codeSign \
          -k /Library/Keychains/System.keychain "$kanataCertTmp/cert.pem"
        /bin/rm -rf "$kanataCertTmp"
      fi

      if [ ! -e "${kanataStableBinary}" ] || [ "$(/bin/cat "${kanataSourceMarker}" 2>/dev/null)" != "${kanataStoreBinary}" ]; then
        /usr/bin/install -m 0555 -o root -g wheel "${kanataStoreBinary}" "${kanataStableBinary}.tmp"
        /usr/bin/codesign --force --timestamp=none \
          --sign "${kanataCertCommonName}" --identifier "${kanataCodesignIdentifier}" \
          "${kanataStableBinary}.tmp"
        /bin/mv "${kanataStableBinary}.tmp" "${kanataStableBinary}"
        printf '%s' "${kanataStoreBinary}" > "${kanataSourceMarker}"
      fi

      karabiner_virtual_hid_version="${karabinerVirtualHid.version}"
      karabiner_virtual_hid_receipt="${karabinerVirtualHid.receipt}"
      karabiner_virtual_hid_installed_version="$(
        /usr/sbin/pkgutil --pkg-info "$karabiner_virtual_hid_receipt" 2>/dev/null \
          | /usr/bin/awk '/^version:/ { print $2; exit }' \
          || true
      )"

      if [ "$karabiner_virtual_hid_installed_version" != "$karabiner_virtual_hid_version" ]; then
        echo "installing Karabiner VirtualHIDDevice $karabiner_virtual_hid_version..." >&2
        /usr/sbin/installer -pkg "${karabinerVirtualHid.pkg}" -target /
      fi
    '';

    launchd.daemons = {
      "karabiner-vhidmanager" = {
        serviceConfig = {
          ProgramArguments = [
            karabinerVirtualHid.managerPath
            "activate"
          ];
          RunAtLoad = true;
          KeepAlive = false;
          UserName = "root";
          StandardOutPath = "/var/log/karabiner-vhidmanager.log";
          StandardErrorPath = "/var/log/karabiner-vhidmanager.log";
        };
      };

      "karabiner-vhiddaemon" = {
        serviceConfig = {
          ProgramArguments = [
            karabinerVirtualHid.daemonPath
          ];
          RunAtLoad = true;
          KeepAlive = true;
          UserName = "root";
          ProcessType = "Interactive";
          StandardOutPath = "/var/log/karabiner-vhiddaemon.log";
          StandardErrorPath = "/var/log/karabiner-vhiddaemon.log";
        };
      };

      kanata = {
        serviceConfig = {
          ProgramArguments = kanataCommandArgs;
          RunAtLoad = true;
          KeepAlive = true;
          UserName = "root";
          ProcessType = "Interactive";
          StandardOutPath = "/var/log/kanata.log";
          StandardErrorPath = "/var/log/kanata.log";
        };
      };
    };
  };
}
