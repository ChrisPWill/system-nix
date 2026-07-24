{
  config,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.envoluntary.homeModules.default
    {
      programs.envoluntary.package =
        inputs.envoluntary.packages.${pkgs.stdenv.hostPlatform.system}.default;
    }
  ];

  programs.envoluntary.enable = true;

  # Keep mappings immediately editable. Envoluntary refreshes its cached profile
  # when the referenced flake changes.
  xdg.configFile."envoluntary/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/dev/envoluntary/envoluntary.toml";
}
