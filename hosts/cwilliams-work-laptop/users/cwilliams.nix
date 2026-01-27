{
  config,
  inputs,
  lib,
  ...
}: {
  options = with lib; {
    workLaptopHomeDir = mkOption {
      type = types.str;
      description = "The directory this file lives in (for out of store symlinks)";
      default = "${config.nixConfigDir}/hosts/cwilliams-work-laptop/users";
    };
  };

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
    xdg.configFile."envoluntary/config.toml".source = config.lib.file.mkOutOfStoreSymlink "${config.workLaptopHomeDir}/out-of-store/envoluntary.toml";

    # Enable copilot
    nixCats.custom.enableCopilot = true;
  };
}
