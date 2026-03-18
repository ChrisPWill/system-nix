{
  config,
  inputs,
  ...
}: {
  imports = [inputs.self.homeModules.home-shared];

  config = {
    userEmail = "cwilliams@atlassian.com";

    isAtlassianMachine = true;

    home.sessionPath = [
      # Add Atlassian tools to PATH
      "/opt/atlassian/bin"
      # pip and other stuff
      "${config.home.homeDirectory}/.local/bin"
    ];

    # Envoluntary configuration
    xdg.configFile."envoluntary/config.toml".source = config.lib.file.mkOutOfStoreSymlink "${config.nixConfigDir}/hosts/cwilliams-work-laptop/users/envoluntary.toml";

    # Enable copilot
    nixCats.custom.enableCopilot = true;
  };
}
