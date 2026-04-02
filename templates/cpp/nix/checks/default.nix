{pkgs, ...}:
pkgs.stdenv.mkDerivation {
  pname = "my_project-check";
  version = "1.0";

  src = ../../.;

  nativeBuildInputs = with pkgs; [
    cmake
    ninja
    just
    cppcheck
    clang-tools # for clang-tidy
    treefmt
    alejandra
  ];

  buildInputs = with pkgs; [
    llvmPackages.libcxx
  ];

  dontConfigure = true;

  buildPhase = ''
    just check
  '';

  installPhase = ''
    touch $out
  '';

  doCheck = true;
}
