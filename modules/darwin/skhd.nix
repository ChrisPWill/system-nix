{
  lib,
  pkgs,
  ...
}: let
  skhdStoreBinary = "${pkgs.skhd}/bin/skhd";
  skhdStableDir = "/Library/Application Support/Skhd";
  skhdStableBinary = "${skhdStableDir}/skhd";
  skhdSourceMarker = "${skhdStableDir}/.source-store-path";
  # macOS keys Accessibility grants for unsigned/ad-hoc binaries by code hash.
  # Keep a locally signed stable binary so a nixpkgs skhd update does not make
  # macOS treat the LaunchAgent as an untrusted new client.
  skhdCertCommonName = "org.nixos.skhd-codesign";
  skhdCodesignIdentifier = "org.nixos.skhd";
in {
  config = lib.mkIf pkgs.stdenv.isDarwin {
    environment.systemPackages = [
      pkgs.skhd
      (pkgs.writeShellScriptBin "skhd-healthcheck" ''
        set -u

        skhd_service="gui/$(/usr/bin/id -u)/org.nix-community.home.skhd"
        skhd_binary="${skhdStableBinary}"
        log_window="''${SKHD_HEALTHCHECK_WINDOW:-20m}"
        probe=0
        status=0

        case "''${1:-}" in
          --probe) probe=1 ;;
          "") ;;
          *)
            /bin/echo "usage: skhd-healthcheck [--probe]" >&2
            exit 2
            ;;
        esac

        /bin/echo "Checking $skhd_service..."
        if service_state="$(/bin/launchctl print "$skhd_service" 2>/dev/null)"; then
          /bin/echo "$service_state" | /usr/bin/grep -E 'state =|pid =|job state'
        else
          /bin/echo "FAIL: LaunchAgent is not loaded." >&2
          status=1
        fi

        if /usr/bin/codesign --verify --strict --verbose=2 "$skhd_binary"; then
          /bin/echo "OK: skhd binary signature is valid."
        else
          /bin/echo "FAIL: skhd binary signature is invalid; re-run a system switch." >&2
          status=1
        fi

        # skhd only checks Accessibility at startup, but its CGEventTap needs
        # Input Monitoring (kTCCServiceListenEvent). When only the latter is
        # broken skhd stays running and logs nothing, so hotkeys die silently --
        # the signature and LaunchAgent checks above both stay green.
        #
        # TCC grants are keyed to the client's own code identity, so no separate
        # helper can query skhd's grant; it would report its own. tccd's log is
        # the only privilege-free evidence: it names the subject path when a
        # stored code requirement no longer matches the binary's current one.
        if [ "$probe" -eq 1 ]; then
          # Force WindowServer to re-evaluate now rather than waiting for an
          # incidental check to happen to land inside the log window.
          /bin/echo "Probing: restarting $skhd_service to force a fresh TCC check..."
          /bin/launchctl kickstart -k "$skhd_service" || status=1
          /bin/sleep 5
          log_window=1m
        fi

        tcc_log="$(/usr/bin/log show --last "$log_window" \
          --predicate 'subsystem == "com.apple.TCC"' --style compact 2>/dev/null \
          | /usr/bin/grep -F "$skhd_binary")" || true

        if [ -z "$tcc_log" ]; then
          /bin/echo "INCONCLUSIVE: no TCC activity for skhd in the last $log_window."
          /bin/echo "  Re-run as 'skhd-healthcheck --probe' to force a check."
        elif /bin/echo "$tcc_log" | /usr/bin/grep -qF 'Failed to match existing code requirement'; then
          /bin/echo "FAIL: macOS holds a stale permission record for skhd." >&2
          /bin/echo "$tcc_log" | /usr/bin/grep -F 'Failed to match existing code requirement' >&2
          /bin/echo "" >&2
          /bin/echo "The binary was re-signed after the grant was recorded, so the stored" >&2
          /bin/echo "requirement no longer matches. Note that 'tccutil reset' cannot fix" >&2
          /bin/echo "this: skhd is not an app bundle, so it has no bundle identifier." >&2
          /bin/echo "" >&2
          /bin/echo "Stop the agent first -- revoking a permission from a running input" >&2
          /bin/echo "client can leave Secure Event Input stuck, which kills the keyboard" >&2
          /bin/echo "until you reboot:" >&2
          /bin/echo "  launchctl bootout $skhd_service" >&2
          /bin/echo "" >&2
          /bin/echo "Then in System Settings > Privacy & Security, under BOTH Accessibility" >&2
          /bin/echo "and Input Monitoring, select the skhd entry and click - to delete it" >&2
          /bin/echo "(toggling it off leaves the stale record), then click + and add:" >&2
          /bin/echo "  $skhd_binary" >&2
          status=1
        else
          /bin/echo "OK: TCC accepted skhd's code requirement (Accessibility and Input Monitoring)."
        fi

        exit "$status"
      '')
    ];

    system.activationScripts.extraActivation.text = lib.mkAfter ''
      /bin/mkdir -p "${skhdStableDir}"
      /usr/sbin/chown root:wheel "${skhdStableDir}"
      /bin/chmod 0755 "${skhdStableDir}"

      if ! /usr/bin/security find-certificate -c "${skhdCertCommonName}" /Library/Keychains/System.keychain >/dev/null 2>&1; then
        echo "generating self-signed code-signing certificate for skhd..." >&2
        skhd_cert_tmp="$(/usr/bin/mktemp -d)"
        ${pkgs.openssl}/bin/openssl req -x509 -newkey rsa:2048 \
          -keyout "$skhd_cert_tmp/key.pem" -out "$skhd_cert_tmp/cert.pem" \
          -days 36500 -nodes -subj "/CN=${skhdCertCommonName}" \
          -addext "keyUsage=critical,digitalSignature" \
          -addext "extendedKeyUsage=codeSigning" \
          -addext "basicConstraints=critical,CA:false"
        ${pkgs.openssl}/bin/openssl pkcs12 -export -legacy \
          -out "$skhd_cert_tmp/cert.p12" \
          -inkey "$skhd_cert_tmp/key.pem" -in "$skhd_cert_tmp/cert.pem" \
          -keypbe PBE-SHA1-3DES -certpbe PBE-SHA1-3DES -macalg sha1 \
          -passout pass:skhd-codesign-transient
        /usr/bin/security import "$skhd_cert_tmp/cert.p12" -k /Library/Keychains/System.keychain \
          -P skhd-codesign-transient -T /usr/bin/codesign -T /usr/bin/security
        /usr/bin/security add-trusted-cert -d -r trustRoot -p codeSign \
          -k /Library/Keychains/System.keychain "$skhd_cert_tmp/cert.pem"
        /bin/rm -rf "$skhd_cert_tmp"
      fi

      if [ ! -e "${skhdStableBinary}" ] \
        || [ "$(/bin/cat "${skhdSourceMarker}" 2>/dev/null)" != "${skhdStoreBinary}" ] \
        || ! /usr/bin/codesign --verify --strict "${skhdStableBinary}" >/dev/null 2>&1; then
        /usr/bin/install -m 0555 -o root -g wheel "${skhdStoreBinary}" "${skhdStableBinary}.tmp"
        /usr/bin/codesign --force --timestamp=none \
          --sign "${skhdCertCommonName}" --identifier "${skhdCodesignIdentifier}" \
          "${skhdStableBinary}.tmp"
        /bin/mv "${skhdStableBinary}.tmp" "${skhdStableBinary}"
        printf '%s' "${skhdStoreBinary}" > "${skhdSourceMarker}"
      fi
    '';
  };
}
