{config, inputs, lib, ...}: {
  options = with lib; {
    workLaptopHomeDir = mkOption {
      type = types.str;
      description = "The home directory for Chris Williams' work laptop";
      default = "${config.nixConfigDir}/hosts/cwilliams-work-laptop/users";
    };
  };

  imports = [inputs.self.homeModules.home-shared];

  config = {
    userEmail = "cwilliams@atlassian.com";

    # Add Atlassian tools to PATH
    home.sessionPath = ["/opt/atlassian/bin"];

    # Envoluntary configuration
    xdg.configFile."envoluntary/config.toml".source = config.lib.file.mkOutOfStoreSymlink "${config.workLaptopHomeDir}/out-of-store/envoluntary.toml";

    # Enable copilot
    nixCats.custom.enableCopilot = true;
  };
}
