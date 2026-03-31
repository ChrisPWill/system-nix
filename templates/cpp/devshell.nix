{pkgs, ...}:
  pkgs.mkShell {
    # Add build dependencies
    packages = with pkgs; [
      # Compilers
      gcc
      llvmPackages.clang
      llvmPackages.libcxx # Standard C++ library (LLVM)
      
      # Build Systems
      cmake
      ninja
      meson
      gnumake
      just
      
      # LSP & Tools
      clang-tools # Includes clangd, clang-format, clang-tidy
      
      # Debuggers
      gdb
      lldb

      # Quality & Analysis
      cppcheck
      include-what-you-use
      
      # Documentation
      doxygen
    ];

    # Load custom bash code
    shellHook = ''
      export PS1="(cpp) $PS1"
      echo "Welcome to your C++ development environment!"
      echo "Run 'just' to see available commands."
    '';
  }
