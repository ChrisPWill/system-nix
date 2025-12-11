{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.niri.nixosModules.niri
  ];
  config = {
    programs.niri.enable = true;
    programs.niri.package = pkgs.niri;

    environment.systemPackages = with pkgs; [
      # Required by niri on nvidia drivers
      xwayland-satellite
    ];
  };
}
