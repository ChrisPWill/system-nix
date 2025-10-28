local wezterm = require 'wezterm'

return {
  front_end = "WebGpu",

  font = wezterm.font {
    family = "FantasqueSansM Nerd Font Mono",
  },
  font_size = 16.0,
  color_scheme = "chrisTheme",
  window_background_opacity = 0.9,
  macos_window_background_blur = 20,

  -- default_prog = { '@nushell@/bin/nu' }
}
