# Builds the locked-down Intuit laptop with nothing approved and fails if any
# app still installs. A tool added to a shared module without an appApproved
# gate would otherwise reach that laptop without IT approval.
{
  inputs,
  pkgs,
  system,
  ...
}: let
  inherit (pkgs) lib;

  withNothingApproved = configuration:
    (configuration.extendModules {
      modules = [{approvedApps = lib.mkForce [];}];
    })
    .config;

  home = withNothingApproved inputs.self.legacyPackages.${system}.homeConfigurations."cwilliams@cwilliams-intuit-laptop";
  darwin = withNothingApproved inputs.self.darwinConfigurations.cwilliams-intuit-laptop;

  # Fonts, theming and the tools that apply this configuration aren't apps.
  exemptPackages = [
    "adw-gtk3"
    "dejavu-fonts"
    "dummy-fc-dir1"
    "dummy-fc-dir2"
    "hm-session-vars.sh"
    "home-configuration-reference-manpage"
    "home-manager"
    "nerd-fonts-fantasque-sans-mono"
    "noto-fonts-cjk-sans"
    "noto-fonts-color-emoji"
  ];

  # Stylix writes theme files for apps whether or not they're installed. The
  # rest configure Nix, fonts and macOS's built-in ssh.
  exemptFilePatterns = [
    ".*[Ss]tylix.*"
    ".*gtk.*"
    ".*/\\.Xresources"
    ".*/forge/stylesheet/.*"
    ".*/gdu/gdu\\.yaml"
    ".*/flatpak/overrides/global"
    ".*/fontconfig/.*"
    "Library/Fonts/.*"
    ".*/nix/(nix\\.conf|registry\\.json)"
    "\\.ssh/config"
    ".*/\\.keep"
    "Applications/Home Manager Apps"
  ];

  # What nix-darwin installs to manage the machine at all.
  exemptSystemPackages = [
    "bash-interactive"
    "brew"
    "darwin-option"
    "darwin-rebuild"
    "darwin-version"
    "stale-cask-apps-check"
    "texinfo-interactive"
    "zsh"
  ];

  nameOf = p: p.pname or p.name;
  exempt = patterns: path: lib.any (pattern: builtins.match pattern path != null) patterns;

  unapproved = {
    "Home Manager packages" = lib.filter (p: !(lib.elem p exemptPackages)) (map nameOf home.home.packages);
    "Home Manager files" = lib.filter (f: !(exempt exemptFilePatterns f)) (lib.attrNames (lib.filterAttrs (_: f: f.enable) home.home.file));
    "Home Manager launchd agents" = lib.attrNames (lib.filterAttrs (_: a: a.enable) home.launchd.agents);
    "nix-darwin packages" = lib.filter (p: !(lib.elem p exemptSystemPackages)) (map nameOf darwin.environment.systemPackages);
    "Homebrew casks" = map (c: c.name) darwin.homebrew.casks;
    "nix-darwin daemons" = lib.remove "activate-system" (lib.attrNames darwin.launchd.daemons);
    "nix-darwin user agents" = lib.remove "set-gui-path" (lib.attrNames darwin.launchd.user.agents);
  };

  failures = lib.filterAttrs (_: found: found != []) unapproved;
  report = lib.concatStringsSep "\n" (lib.mapAttrsToList (kind: found: "${kind}: ${lib.concatStringsSep ", " found}") failures);
in
  pkgs.runCommandLocal "approved-apps-check" {
    meta.platforms = lib.platforms.darwin;
  } (
    if failures == {}
    then "touch $out"
    else ''
      echo "cwilliams-intuit-laptop installs these with nothing approved; gate each with config.appApproved.<name>:" >&2
      printf '%s\n' ${lib.escapeShellArg report} >&2
      exit 1
    ''
  )
