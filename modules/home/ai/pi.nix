{
  pkgs,
  lib,
  ...
}: let
  pi-agent = pkgs.rustPlatform.buildRustPackage rec {
    pname = "pi-agent";
    version = "0.1.15";

    src = pkgs.fetchFromGitHub {
      owner = "Dicklesworthstone";
      repo = "pi_agent_rust";
      rev = "c91170a952427b94e0951ef2a724941baa0f0863";
      hash = "sha256-mBP1qIsHOH3DaTk7X32f26V1kc3Kt3YEEvam80ed5Go=";
    };

    # Use the pre-fetched hash if I can confirm it, but the one from nix-prefetch-url --unpack 
    # needs to be converted. 
    # Let's just use a dummy and let it fail to get the correct one.
    
    cargoHash = "sha256-1R1oQzh03UAUzQPdq1nYKcVVookPKyaTivabCLCjDNY=";

    nativeBuildInputs = [
      pkgs.pkg-config
      pkgs.makeWrapper
      pkgs.fd
      pkgs.ripgrep
    ];

    buildInputs = [
      pkgs.openssl
      pkgs.sqlite
    ];

    # Tests fail in the Nix sandbox due to missing dependencies (python3) 
    # and lack of TTY for TUI tests.
    doCheck = false;

    # Wrap the binary to ensure fd and ripgrep are available at runtime
    postInstall = ''
      wrapProgram $out/bin/pi \
        --prefix PATH : ${lib.makeBinPath [pkgs.fd pkgs.ripgrep]}
    '';

    meta = with lib; {
      description = "High-performance AI agent in Rust";
      homepage = "https://github.com/Dicklesworthstone/pi_agent_rust";
      license = licenses.mit;
      mainProgram = "pi";
    };
  };
in {
  home.packages = [pi-agent];
}
