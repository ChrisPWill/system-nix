{
  description = "Simple flake with a devshell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # https://github.com/numtide/blueprint
    # Used for managing flake via standard folder structure
    blueprint.url = "github:numtide/blueprint";
    blueprint.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  # Load config via blueprint https://github.com/numtide/blueprint
  outputs = inputs: inputs.blueprint {inherit inputs;};
}
