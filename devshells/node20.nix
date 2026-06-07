{pkgs, ...}: let
  inherit (pkgs) stdenv;
in
  pkgs.mkShell {
    # Add build dependencies
    packages = with pkgs; [
      nodejs_22
      (yarn.override {
        nodejs = nodejs_22;
      })
    ];

    env = {
      # Set npm global packages path
      npm_config_prefix = "${
        if stdenv.isDarwin
        then "/Users"
        else "/home"
      }/cwilliams/.node22-packages";
    };

    # Load custom bash code
    shellHook = ''
      # Add node22 packages bin to PATH
      export PATH="${
        if stdenv.isDarwin
        then "/Users"
        else "/home"
      }/cwilliams/.node22-packages/bin:$PATH"

      export PS1="(node22) $PS1"
    '';
  }
