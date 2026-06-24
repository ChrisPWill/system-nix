{
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.self.homeModules.home-shared
    inputs.self.homeModules.work-machine
    inputs.self.homeModules.sequence
  ];

  config = {
    home.sessionPath = [
      # pip and other stuff
      "${config.home.homeDirectory}/.local/bin"
    ];

    # Envoluntary configuration
    xdg.configFile."envoluntary/config.toml".source = config.lib.file.mkOutOfStoreSymlink "${config.nixConfigDir}/hosts/cwilliams-work-laptop/users/envoluntary.toml";

    # Enable copilot
    nixCats.custom.enableCopilot = true;
  };
}
