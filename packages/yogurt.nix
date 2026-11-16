{pkgs, ...}: let
  inherit (pkgs) fetchurl lib stdenvNoCC unzip;
  version = "0.3.30";
  # Release builds are signed by the developer. Building from source would
  # need its pnpm and native toolchain and lose the signature, which macOS
  # ties the microphone and screen recording permissions to. The app's own
  # updater can't write to the store, so updates mean bumping the version.
  #
  # The zip rather than the DMG: 7-Zip unpacks the DMG's extended attributes
  # as extra files inside the bundle, which invalidates the signature.
  sources = {
    aarch64-darwin = {
      url = "https://github.com/FrigadeHQ/yogurt/releases/download/v${version}/Yogurt-mac-arm64.zip";
      hash = "sha256-522thY3Y8gchYfLyH3BrA2Eycl0G6XaHyYN4Lvhncxs=";
    };
  };
in
  stdenvNoCC.mkDerivation {
    pname = "yogurt";
    inherit version;

    src = fetchurl sources.${stdenvNoCC.hostPlatform.system};

    nativeBuildInputs = [unzip];
    sourceRoot = "Yogurt.app";

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/Applications"
      cp -R . "$out/Applications/Yogurt.app"
      runHook postInstall
    '';

    # Fixup would rewrite the binaries and break the code signature.
    dontFixup = true;

    meta = {
      description = "Private AI meeting notes that run locally";
      homepage = "https://yogurt.so";
      license = lib.licenses.mit;
      platforms = builtins.attrNames sources;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
