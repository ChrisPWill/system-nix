{pkgs, ...}:
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
    npm_config_prefix = "/Users/cwilliams/.node20-packages";
  };

  # Load custom bash code
  shellHook = ''
  '';
}
