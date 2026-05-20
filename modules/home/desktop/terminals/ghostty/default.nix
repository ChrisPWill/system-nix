{
  config,
  lib,
  ...
}: {
  xdg.configFile."ghostty/config.dynamic".source = config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/desktop/terminals/ghostty/ghostty.config";
  xdg.configFile."ghostty/shaders".source = config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/desktop/terminals/ghostty/shaders";

  programs.ghostty = {
    enable = true;
    settings = lib.mkMerge [
      {
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
      }
      # Inject Stylix colors if native target is insufficient or for explicit control
      (lib.mkIf (config.stylix.enable && (config.stylix.targets.ghostty.enable or true)) {
        background = "#${config.lib.stylix.colors.base00}";
        foreground = "#${config.lib.stylix.colors.base05}";
        cursor-color = "#${config.lib.stylix.colors.base05}";

        palette = [
          "0=#${config.lib.stylix.colors.base00}"
          "1=#${config.lib.stylix.colors.base08}"
          "2=#${config.lib.stylix.colors.base0B}"
          "3=#${config.lib.stylix.colors.base0A}"
          "4=#${config.lib.stylix.colors.base0D}"
          "5=#${config.lib.stylix.colors.base0E}"
          "6=#${config.lib.stylix.colors.base0C}"
          "7=#${config.lib.stylix.colors.base05}"
          "8=#${config.lib.stylix.colors.base03}"
          "9=#${config.lib.stylix.colors.base08}"
          "10=#${config.lib.stylix.colors.base0B}"
          "11=#${config.lib.stylix.colors.base0A}"
          "12=#${config.lib.stylix.colors.base0D}"
          "13=#${config.lib.stylix.colors.base0E}"
          "14=#${config.lib.stylix.colors.base0C}"
          "15=#${config.lib.stylix.colors.base07}"
        ];
      })
    ];
  };
}
