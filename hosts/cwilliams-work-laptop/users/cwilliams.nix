{inputs, ...}: {
  imports = [inputs.self.homeModules.home-shared];

  userEmail = "cwilliams@atlassian.com";

  # Add Atlassian tools to PATH
  home.sessionPath = ["/opt/atlassian/bin"];
}
