{
  inputs,
  pkgs,
  ...
}: {
  # Disable Stylix's kmscon module because it sets services.kmscon.extraConfig and services.kmscon.fonts,
  # which have been removed/deprecated in newer nixpkgs.
  disabledModules = [
    "${inputs.stylix}/modules/kmscon/nixos.nix"
  ];

  stylix = {
    enable = true;
    # nix-darwin and Stylix both track their upstream unstable branches here, so
    # their release metadata can disagree briefly even while they share nixpkgs.
    enableReleaseChecks = false;
    base16Scheme = "${inputs.stylix.inputs.tinted-schemes}/base16/onedark.yaml";

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.fantasque-sans-mono;
        name = "FantasqueSansM Nerd Font Mono";
      };
      sizes.terminal = 12;
    };

    opacity.terminal = 0.9;
  };
}
