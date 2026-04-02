{pkgs, ...}:
pkgs.stdenv.mkDerivation {
  pname = "my_project";
  version = "1.0";

  src = ../../.;

  nativeBuildInputs = with pkgs; [
    cmake
    ninja
  ];

  buildInputs = with pkgs; [
    # Add library dependencies here (e.g., fmt, boost, openssl)
  ];

  cmakeFlags = [
    "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
  ];
}
