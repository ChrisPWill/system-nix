{
  description = "Simple flake with a devshell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-small.url = "github:NixOS/nixpkgs/nixos-unstable-small";

    # https://github.com/numtide/blueprint
    # Used for managing flake via standard folder structure
    blueprint.url = "github:numtide/blueprint";
    blueprint.inputs.nixpkgs.follows = "nixpkgs";

    # Needed to overcome error in envoluntary, can maybe remove later
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";

    # https://github.com/dfrankland/envoluntary
    # direnv-like matcher that avoids needing to create gitignored nix files in projects
    # Return dfrankland to config when https://github.com/dfrankland/envoluntary/pull/29 is merged
    envoluntary.url = "github:dfrankland/envoluntary";
    envoluntary.inputs.nixpkgs.follows = "nixpkgs";
    envoluntary.inputs.home-manager.follows = "home-manager";
    envoluntary.inputs.rust-overlay.follows = "rust-overlay";

    # Darwin things
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Migrating to nixCats
    nixCats.url = "github:BirdeeHub/nixCats-nvim";

    niri.url = "github:sodiboo/niri-flake";
    niri.inputs.nixpkgs.follows = "nixpkgs";

    # Used for system monitoring in Dank Material Shell
    dgop.url = "github:AvengeMedia/dgop";
    dgop.inputs.nixpkgs.follows = "nixpkgs";

    dankMaterialShell = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.dgop.follows = "dgop";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Load config via blueprint https://github.com/numtide/blueprint
  outputs = inputs:
    inputs.blueprint {
      inherit inputs;

      nixpkgs.config.allowUnfree = true;
    };
}
