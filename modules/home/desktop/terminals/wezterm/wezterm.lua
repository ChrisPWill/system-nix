local wezterm = require("wezterm")

return {
	front_end = "WebGpu",

	font = wezterm.font({
		family = "FantasqueSansM Nerd Font Mono",
	}),
	-- color_scheme = "chrisTheme",
	window_background_opacity = 0.9,
	macos_window_background_blur = 20,
	hide_tab_bar_if_only_one_tab = true,

	-- default_prog = { "nu" },
}
