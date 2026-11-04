{
  config,
  inputs,
  pkgs,
  ...
}: {
  home.packages = config.filterApproved {
    # JSON formatting etc.
    inherit (pkgs) jq;
  };

  imports = [
    inputs.envoluntary.homeModules.default
    ({pkgs, ...}: {programs.envoluntary.package = inputs.envoluntary.packages.${pkgs.stdenv.hostPlatform.system}.default;})
  ];

  programs.envoluntary.enable = config.appApproved.envoluntary;
}
