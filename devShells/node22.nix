{pkgs}:
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
    npm_config_prefix = "/Users/cwilliams/.node22-packages";
  };

  # Load custom bash code
  shellHook = ''
  '';
}
