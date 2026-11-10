# Intuit-managed MacBook. Admin rights need an IT request and each app needs
# approval, so Home Manager always runs standalone: switching it never needs
# sudo, even once nix-darwin (../darwin-configuration.nix) manages the
# system. See ../README.md.
{
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.self.homeModules.home-shared
    inputs.self.homeModules.standalone
  ];

  usesDeterminateNix = true;
  programs.home-manager.enable = true;
  dev.nix.separateHomeManager = true;

  isWorkMachine = true;

  # Intuit's network intercepts HTTPS through Zscaler.
  ops.keychainCaBundle.enable = true;

  userEmail = "chris_williams2@intuit.com";

  # IT controls the machine's hostname, so `sw` can't rely on it matching
  # this directory. Rename both together.
  dev.nix.flakeHostName = "cwilliams-intuit-laptop";

  approvedApps = import ../approved-apps.nix;

  # IT installs and updates Chrome, so it isn't in approvedApps.
  home.desktop.wm.macosBrowser = "Google Chrome";

  home.ai = {
    agentProvider = "none";
    neovimProvider = "none";
  };

  programs.gh = {
    enable = config.appApproved.gh;
    settings.git_protocol = "ssh";
  };
}
