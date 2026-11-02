# Intuit-managed MacBook. Admin rights need an IT request and each app needs
# approval. It starts as standalone Home Manager, so switching never needs
# sudo, and moves to nix-darwin (../darwin-configuration.nix) once admin
# rights allow. This file serves both; see ../README.md.
{
  inputs,
  lib,
  ...
} @ args: let
  # nix-darwin passes osConfig to Home Manager; standalone Home Manager
  # doesn't. A default value wouldn't work here: the module system ignores it
  # and looks the argument up in config, which imports can't depend on.
  isStandalone = !(args ? osConfig);
in {
  # nix-darwin's Stylix module already loads Stylix into Home Manager, so
  # only load it here when running without nix-darwin.
  imports =
    [inputs.self.homeModules.home-shared]
    ++ lib.optionals isStandalone [inputs.self.homeModules.standalone];

  usesDeterminateNix = true;
  programs.home-manager.enable = isStandalone;

  isWorkMachine = true;

  userEmail =
    lib.warn
    "hosts/cwilliams-intuit-laptop: userEmail is a placeholder, so git commits use a made-up address; set your Intuit email"
    "REPLACE-ME@intuit.com";

  # IT controls the machine's hostname, so `sw` can't rely on it matching
  # this directory. Rename both together.
  dev.nix.flakeHostName = "cwilliams-intuit-laptop";

  # Add a name once IT approves the app. The full list of names is gatedApps
  # in modules/home/home-shared.nix. nix-darwin reads this list too, for
  # casks and system services such as Kanata.
  approvedApps = [];

  home.ai = {
    agentProvider = "none";
    neovimProvider = "none";
  };

  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };
}
