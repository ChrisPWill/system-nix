{pkgs, ...}: let
  inherit (pkgs) fetchurl jdk25 lib stdenv unzip;
  autoPatchelfHook = pkgs.autoPatchelfHook or null;
  version = "262.8190.0";
  sources = {
    aarch64-darwin = {
      url = "https://download-cdn.jetbrains.com/language-server/kotlin-server/${version}/kotlin-server-${version}-aarch64.sit";
      hash = "sha256-4gGDJieEu35mXOGupIVYcqixbyEeu0eNRSdzVTcy2fs=";
    };
    x86_64-linux = {
      url = "https://download-cdn.jetbrains.com/language-server/kotlin-server/${version}/kotlin-server-${version}.tar.gz";
      hash = "sha256-i0xw6VBlQg54Z8mar58Y4LTnYxHsRT5MGjnj9q53TL8=";
    };
  };
  source = sources.${stdenv.hostPlatform.system};
in
  stdenv.mkDerivation {
    pname = "kotlin-lsp";
    inherit version;

    src = fetchurl source;

    nativeBuildInputs =
      lib.optionals stdenv.hostPlatform.isDarwin [unzip]
      ++ lib.optionals stdenv.hostPlatform.isLinux [autoPatchelfHook];

    sourceRoot = "kotlin-server-${version}";

    unpackPhase = ''
      runHook preUnpack
      ${
        if stdenv.hostPlatform.isDarwin
        then ''unzip "$src"''
        else ''tar -xzf "$src"''
      }
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/libexec/kotlin-lsp" "$out/bin"
      cp -R . "$out/libexec/kotlin-lsp/"

      ${lib.optionalString stdenv.hostPlatform.isLinux ''
        rm -rf "$out/libexec/kotlin-lsp/jbr"
        ln -s ${jdk25} "$out/libexec/kotlin-lsp/jbr"
      ''}

      ln -s ../libexec/kotlin-lsp/bin/intellij-server "$out/bin/kotlin-lsp"

      runHook postInstall
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck
      "$out/bin/kotlin-lsp" --version 2>&1 | grep -F "${version}"
      runHook postInstallCheck
    '';

    meta = {
      description = "Official JetBrains language server for Kotlin";
      homepage = "https://github.com/Kotlin/kotlin-lsp";
      license = lib.licenses.unfree;
      mainProgram = "kotlin-lsp";
      platforms = builtins.attrNames sources;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
