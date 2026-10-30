{
  pkgs,
  config,
  lib,
  ...
}: {
  xdg.configFile."ghostty/config.dynamic".source = config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/desktop/terminals/ghostty/ghostty.config";
  xdg.configFile."ghostty/shaders".source = config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/desktop/terminals/ghostty/shaders";

  programs.ghostty = {
    enable = true;
    # macOS gets Ghostty from the Homebrew cask; Home Manager only writes its config.
    package = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin null;
    settings = {
      # --- Visuals ---
      macos-titlebar-style = "hidden";
      background-blur = true;
      window-padding-x = 5;
      window-padding-y = 5;

      # --- Fonts ---
      font-size = config.terminalFontSize;

      # --- Behavior ---
      link-previews = "osc8"; # Show a preview if the link doesn't match text
      config-file = "?config.dynamic";

      # --- Keybindings ---
      keybind = [
        "super+enter=new_window"
        "super+t=new_tab"
      ];

      # --- Shaders (Declarative) ---
      custom-shader = [
        "shaders/cursor_warp.glsl"
        "shaders/rectangle_boom_cursor.glsl"
      ];
    };
  };
}
