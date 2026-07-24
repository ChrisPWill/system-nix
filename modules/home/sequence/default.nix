{config, ...}: {
  isWorkMachine = true;
  userEmail = "chris.williams@sequencehq.com";

  programs = {
    gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
      };
    };
  };

  # Keep employer repository mappings immediately editable without rebuilding
  # this flake's source into the Nix store.
  xdg.configFile."envoluntary/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/sequence/envoluntary.toml";
}
