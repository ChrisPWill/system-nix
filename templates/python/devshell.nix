{pkgs, ...}: let
  inherit (pkgs) stdenv;
in
  pkgs.mkShell {
    packages = with pkgs; [
      python314
    ];

    shellHook = ''
      export PIP_PREFIX="${
        if stdenv.isDarwin
        then "/Users"
        else "/home"
      }/cwilliams/.pip_packages"
      export PYTHONPATH="$PIP_PREFIX/${pkgs.python3.sitePackages}:$PYTHONPATH"
      export PATH="$PIP_PREFIX/bin:$PATH"
      unset SOURCE_DATE_EPOCH # Allow pip to install wheels
    '';
  }
