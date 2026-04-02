{config, ...}: {
  programs.wezterm.enable = true;
  # Copy the wezterm.lua file to the home module directory
  xdg.configFile."wezterm/extraWezterm.lua".source = config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/desktop/terminals/wezterm/wezterm.lua";
  programs.wezterm.extraConfig = "local extraConfig = require('extraWezterm'); return extraConfig";
}
