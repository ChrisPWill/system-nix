{
  inputs,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # JSON formatting etc.
    jq
    inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.rust-docs-mcp-server
  ];

  imports = [
    inputs.envoluntary.homeModules.default
    ({pkgs, ...}: {programs.envoluntary.package = inputs.envoluntary.packages.${pkgs.stdenv.hostPlatform.system}.default;})
  ];

  programs.envoluntary.enable = true;
}
