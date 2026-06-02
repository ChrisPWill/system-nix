# Task: Configure OmniWM Settings

**Objective:** Set up the visual and behavioral preferences for OmniWM.

## Steps

1.  **Create Home Manager Module**:
    - Create `modules/home/desktop/wm/omniwm/default.nix`.
2.  **Define TOML Config**:
    - Use `xdg.configFile."omniwm/settings.toml"` to manage the configuration.
    - Set gaps, borders (if not using `jankyborders`), and app-specific tiling rules.
3.  **Sync**:
    - Update `modules/home/desktop/default.nix` to include the new `omniwm` module.
4.  **Autostart & Sequencing**:
    - Create a `launchd` user agent for OmniWM in `hosts/cwilliams-work-laptop/darwin-configuration.nix`.
    - **Sequencing:** Add a delay or a check to ensures it starts _after_ the Kanata system daemon is active to avoid raw key events during the first few seconds of login.
5.  **Move migration plan to completed**:
    - After implementation and verification, move this file to `planning/migrations/completed/`.

## Improvement Opportunities

- **Visual Parity:** Align gaps and border widths in OmniWM with Niri's `dank.nix` configuration.
- **Dynamic Theming:** Ensure OmniWM picks up the `stylix` colors used elsewhere in the project to maintain "zero-friction switching" visual cues.
- **Niri-style Layout:** Since OmniWM is "Niri and Hyprland inspired", we will attempt to replicate the "scrolling columns" feel of Niri if supported.
