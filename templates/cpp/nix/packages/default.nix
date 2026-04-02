{pkgs, ...}:
pkgs.stdenv.mkDerivation {
  pname = "my_project";
  version = "1.0";

  src = pkgs.lib.cleanSourceWith {
    src = ../../.;
    filter = name: type: let baseName = baseNameOf (toString name); in !(type == "directory" && (baseName == "build" || baseName == ".direnv"));
  };

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
