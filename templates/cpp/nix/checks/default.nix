{pkgs, ...}:
pkgs.stdenv.mkDerivation {
  pname = "my_project-check";
  version = "1.0";

  src = pkgs.lib.cleanSourceWith {
    src = ../../.;
    filter = name: type: let baseName = baseNameOf (toString name); in !(type == "directory" && (baseName == "build" || baseName == ".direnv"));
  };

  nativeBuildInputs = with pkgs; [
    cmake
    ninja
    just
    ccache
    ncurses
    cppcheck
    clang-tools # for clang-tidy
    treefmt
    alejandra
  ];

  buildInputs = with pkgs; [
    llvmPackages.libcxx
    doctest
  ];

  dontConfigure = true;

  env.CCACHE_DISABLE = "1";

  buildPhase = ''
    just check
    just test
  '';

  installPhase = ''
    touch $out
  '';

  doCheck = true;
}
