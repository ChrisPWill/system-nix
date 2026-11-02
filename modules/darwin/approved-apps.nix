{
  config,
  lib,
  ...
}: {
  # The approved list lives in the primary user's Home Manager config, so a
  # host keeps one list whether it runs nix-darwin or standalone Home Manager.
  options.appApproved = lib.mkOption {
    type = lib.types.attrsOf lib.types.bool;
    readOnly = true;
    default = config.home-manager.users.${config.system.primaryUser}.appApproved;
    description = "Whether each gated app is approved on this machine. See approvedApps in modules/home/home-shared.nix.";
  };
}
