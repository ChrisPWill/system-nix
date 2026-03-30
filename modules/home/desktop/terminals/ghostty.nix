{config, ...}: {
  xdg.configFile."ghostty/config.dynamic".source = config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/desktop/terminals/ghostty.config";

  programs.ghostty = {
    enable = true;
    settings = {
      # Visuals
      macos-titlebar-style = "hidden";
      background-blur = true;
      window-padding-x = 5;
      window-padding-y = 5;

      link-previews = "os8"; # Show a preview if the link doesn't match text

      config-file = "?config.dynamic";
    };
  };
}
