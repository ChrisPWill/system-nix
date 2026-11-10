{pkgs, ...}: let
  inherit (pkgs) _7zz fetchurl lib stdenvNoCC;
  version = "0.1.1";
  # Release builds are signed and notarised by the developer. Building from
  # source would need its pnpm and Rust toolchain and lose the signature,
  # which macOS ties the Accessibility permission to.
  sources = {
    aarch64-darwin = {
      url = "https://github.com/Xoshbin/asyar/releases/download/v${version}/asyar_${version}_aarch64.dmg";
      hash = "sha256-0Kcy3A/zmD4IhJYR/wk46wg7soYEn+iU0wsC/HcmbdQ=";
    };
    x86_64-darwin = {
      url = "https://github.com/Xoshbin/asyar/releases/download/v${version}/asyar_${version}_x64.dmg";
      hash = "sha256-IkWe/kkwRY5foGwljQmkRKlexp5XvBzmpo8L3Chh8qg=";
    };
  };
in
  stdenvNoCC.mkDerivation {
    pname = "asyar";
    inherit version;

    src = fetchurl sources.${stdenvNoCC.hostPlatform.system};

    nativeBuildInputs = [_7zz];
    # 7-Zip unpacks the disk image's volume into a folder named after it.
    sourceRoot = "asyar/asyar.app";

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/Applications"
      cp -R . "$out/Applications/asyar.app"
      runHook postInstall
    '';

    # Fixup would rewrite the binaries and break the code signature.
    dontFixup = true;

    meta = {
      description = "Privacy-focused, extensible launcher in the style of Raycast";
      homepage = "https://asyar.org";
      license = lib.licenses.gpl3Only;
      platforms = builtins.attrNames sources;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
