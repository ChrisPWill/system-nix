{
  inputs,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # JSON formatting etc.
    jq
  ];

  imports = [
    inputs.envoluntary.homeModules.default
    ({pkgs, ...}: {programs.envoluntary.package = inputs.envoluntary.packages.${pkgs.stdenv.hostPlatform.system}.default;})
  ];

  programs.envoluntary.enable = true;
}
