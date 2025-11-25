{inputs, ...}: {config, ...}: {
  imports = [
    inputs.self.modules.theming.theme
  ];

  config = {
    # Export theme values to environment variables via zsh
    programs.zsh.initContent = ''
      export THEME_BACKGROUND=${config.theme.background}
      export THEME_BACKGROUND_DEFOCUSED=${config.theme.background-defocused}
      export THEME_FOREGROUND=${config.theme.foreground}
      export THEME_NORMAL_WHITE=${config.theme.normal.white}
      export THEME_NORMAL_SILVER=${config.theme.normal.silver}
      export THEME_NORMAL_LIGHTGRAY=${config.theme.normal.lightgray}
      export THEME_NORMAL_DIMGRAY=${config.theme.normal.dimgray}
      export THEME_NORMAL_BLACK=${config.theme.normal.black}
      export THEME_NORMAL_BLUE=${config.theme.normal.blue}
      export THEME_NORMAL_GREEN=${config.theme.normal.green}
      export THEME_NORMAL_CYAN=${config.theme.normal.cyan}
      export THEME_NORMAL_ORANGE=${config.theme.normal.orange}
      export THEME_NORMAL_YELLOW=${config.theme.normal.yellow}
      export THEME_NORMAL_LIGHTRED=${config.theme.normal.lightred}
      export THEME_NORMAL_RED=${config.theme.normal.red}
      export THEME_NORMAL_MAGENTA=${config.theme.normal.magenta}

      export THEME_LIGHT_WHITE=${config.theme.light.white}
      export THEME_LIGHT_SILVER=${config.theme.light.silver}
      export THEME_LIGHT_LIGHTGRAY=${config.theme.light.lightgray}
      export THEME_LIGHT_DIMGRAY=${config.theme.light.dimgray}
      export THEME_LIGHT_GRAY=${config.theme.light.gray}
      export THEME_LIGHT_BLACK=${config.theme.light.black}
      export THEME_LIGHT_BLUE=${config.theme.light.blue}
      export THEME_LIGHT_GREEN=${config.theme.light.green}
      export THEME_LIGHT_CYAN=${config.theme.light.cyan}
      export THEME_LIGHT_YELLOW=${config.theme.light.yellow}
      export THEME_LIGHT_ORANGE=${config.theme.light.orange}
      export THEME_LIGHT_LIGHTRED=${config.theme.light.lightred}
      export THEME_LIGHT_RED=${config.theme.light.red}
      export THEME_LIGHT_MAGENTA=${config.theme.light.magenta}
    '';
  };
}
