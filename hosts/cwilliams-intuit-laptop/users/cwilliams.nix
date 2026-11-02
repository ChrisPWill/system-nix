# Intuit-managed MacBook. Admin rights need an IT request and each app needs
# approval, so Home Manager always runs standalone: switching it never needs
# sudo, even once nix-darwin (../darwin-configuration.nix) manages the
# system. See ../README.md.
{
  inputs,
  lib,
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

  userEmail =
    lib.warn
    "hosts/cwilliams-intuit-laptop: userEmail is a placeholder, so git commits use a made-up address; set your Intuit email"
    "REPLACE-ME@intuit.com";

  # IT controls the machine's hostname, so `sw` can't rely on it matching
  # this directory. Rename both together.
  dev.nix.flakeHostName = "cwilliams-intuit-laptop";

  approvedApps = import ../approved-apps.nix;

  home.ai = {
    agentProvider = "none";
    neovimProvider = "none";
  };

  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };
}
