{inputs, ...}: {
  imports = [inputs.self.homeModules.home-shared];

  programs.git.settings.user.email = "cwilliams@atlassian.com";
}
