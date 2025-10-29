{pkgs, ...}:
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
    npm_config_prefix = "$HOME/.node22-packages";
  };

  # Load custom bash code
  shellHook = ''
    # Add node22 packages bin to PATH
    export PATH="$HOME/.node22-packages/bin:$PATH";
  '';
}
