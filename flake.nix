{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nixpkgs-small.url = "github:NixOS/nixpkgs/nixos-unstable-small";

    # https://github.com/numtide/blueprint
    # Used for managing flake via standard folder structure
    blueprint.url = "github:numtide/blueprint";
    blueprint.inputs.nixpkgs.follows = "nixpkgs";

    # https://github.com/dfrankland/envoluntary
    # direnv-like matcher that avoids needing to create gitignored nix files in projects
    envoluntary.url = "github:dfrankland/envoluntary";
    envoluntary.inputs.nixpkgs.follows = "nixpkgs";
    envoluntary.inputs.home-manager.follows = "home-manager";

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

    dankMaterialShell.url = "github:AvengeMedia/DankMaterialShell";
    dankMaterialShell.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:nix-community/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    nix-monitor.url = "github:antonjah/nix-monitor";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    knowledge-base.url = "github:ChrisPWill/knowledge-base";
    knowledge-base.inputs.nixpkgs.follows = "nixpkgs";

    plugins-neotest-kotlin = {
      url = "github:codymikol/neotest-kotlin";
      flake = false;
    };
  };

  # Load config via blueprint https://github.com/numtide/blueprint
  outputs = inputs:
    inputs.blueprint {
      inherit inputs;

      nixpkgs.config.allowUnfree = true;
      # Allow EOL electron-39.8.10 which is required by various desktop applications (e.g. element-desktop, signal-desktop, discord)
      nixpkgs.config.permittedInsecurePackages = [
        "electron-39.8.10"
      ];
    };
}
