{config, ...}: {
  xdg.configFile."ghostty/config.dynamic".source = config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/desktop/terminals/ghostty/ghostty.config";
  xdg.configFile."ghostty/shaders".source = config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/desktop/terminals/ghostty/shaders";

  programs.ghostty = {
    enable = true;
    settings = {
      # Visuals
      macos-titlebar-style = "hidden";
      background-blur = true;
      window-padding-x = 5;
      window-padding-y = 5;

      link-previews = "osc8"; # Show a preview if the link doesn't match text

      config-file = "?config.dynamic";
    };
  };
}
