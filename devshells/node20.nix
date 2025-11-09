{pkgs, ...}:
let inherit (pkgs) stdenv; in
pkgs.mkShell {
  # Add build dependencies
  packages = with pkgs; [
    nodejs_20
    (yarn.override {
      nodejs = nodejs_20;
    })
  ];

  env = {
    # Set npm global packages path
    npm_config_prefix = "${if stdenv.isDarwin then "/Users" else "/home"}/cwilliams/.node22-packages";
  };

  # Load custom bash code
  shellHook = ''
    # Add node20 packages bin to PATH
    export PATH="${if stdenv.isDarwin then "/Users" else "/home"}/cwilliams/.node22-packages:$PATH"

    export PS1="(node20) $PS1"
  '';
}
