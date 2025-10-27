{inputs, ...}: {
  imports = [inputs.self.homeModules.home-shared];

  programs.git.userEmail = "cwilliams@atlassian.com";
}
