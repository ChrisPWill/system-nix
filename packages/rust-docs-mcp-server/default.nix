{
  pkgs,
  ...
}:

pkgs.rustPlatform.buildRustPackage rec {
  pname = "rust-docs-mcp-server";
  version = "1.3.1";

  src = pkgs.fetchFromGitHub {
    owner = "Govcraft";
    repo = "rust-docs-mcp-server";
    rev = "v${version}";
    hash = "sha256-jSa4qKZEtZZvYfoRReGDDqH039RH/7Dimo3jmcnnwak=";
  };

  cargoHash = "sha256-iw7dRzwH42HBj2r9y5IHHKLmER7QkyFzLjh7Q+dNMao=";

  nativeBuildInputs = [
    pkgs.pkg-config
    pkgs.perl
  ];

  buildInputs = [
    pkgs.openssl
  ];

  meta = with pkgs.lib; {
    description = "MCP server for querying Rust crate documentation";
    homepage = "https://github.com/Govcraft/rust-docs-mcp-server";
    license = licenses.mit;
    mainProgram = "rustdocs_mcp_server";
  };
}
