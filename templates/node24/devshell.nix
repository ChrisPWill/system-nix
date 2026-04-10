{pkgs, ...}: let
  inherit (pkgs) stdenv;
in
  pkgs.mkShell {
    # Add build dependencies
    packages = with pkgs; [
      nodejs_24
      (yarn.override {
        nodejs = nodejs_24;
      })
    ];

    env = {
      # Set npm global packages path
      npm_config_prefix = "${
        if stdenv.isDarwin
        then "/Users"
        else "/home"
      }/cwilliams/.node24-packages";
    };

    # Load custom bash code
    shellHook = ''
      # Add node24 packages bin to PATH
      export PATH="${
        if stdenv.isDarwin
        then "/Users"
        else "/home"
      }/cwilliams/.node24-packages/bin:$PATH"

      export PS1="(node24) $PS1"
    '';
  }
