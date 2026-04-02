{pkgs, ...}:
pkgs.mkShell.override {stdenv = pkgs.llvmPackages.libcxxStdenv;} {
  # Add build dependencies
  nativeBuildInputs = with pkgs; [
    # Compilers
    # (Included in libcxxStdenv: clang)

    # Build Systems
    cmake
    ninja
    meson
    gnumake
    just
    ccache

    # LSP & Tools
    clang-tools # Includes clangd, clang-format, clang-tidy

    # Debuggers
    gdb
    lldb

    # Quality & Analysis
    cppcheck
    include-what-you-use
    treefmt
    alejandra

    # Documentation
    doxygen
  ];

  buildInputs = with pkgs; [
    # (Included in libcxxStdenv: libcxx)
  ];

  # Load custom bash code
  shellHook = ''
    export PS1="(cpp) $PS1"
    cyan=$(tput setaf 6)
    reset=$(tput sgr0)
    echo -e "''${cyan}==> C++ Dev Environment - Available Commands:''${reset}"
    just --list
  '';
}
