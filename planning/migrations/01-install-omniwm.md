# Task: Install OmniWM & Prepare Fallback

**Objective:** Install OmniWM via Homebrew and ensure Aerospace remains available as a fallback.

## Steps
1.  **Modify `modules/darwin/darwin-shared.nix`**:
    - Add `"BarutSRB/tap"` to `homebrew.taps`.
    - Add `"omniwm"` to `homebrew.casks`.
    - Verify `"aerospace"` remains in `homebrew.casks`.
2.  **macOS System Settings**:
    - **Requirement:** Go to *System Settings > Desktop & Dock > Mission Control* and turn **OFF** "Displays have separate Spaces".
    - This is required for OmniWM's multi-monitor workspace management to function correctly.
3.  **Disable Sketchybar on macOS**:
    - Locate where Sketchybar is enabled for Darwin (likely `modules/home/desktop/wm/sketchybar/default.nix` or similar).
    - Add a conditional or comment out the service enablement for `stdenv.isDarwin` to prevent it starting during the migration.
3.  **Run `drs`**:
    - Apply the changes using `darwin-rebuild switch --flake .`.

## Improvement Opportunities
- **Consistency:** Aerospace currently uses `ctrl-alt` as its primary modifier, while Niri (Linux) uses `Mod` (Super). During this migration, we will evaluate if `Cmd` or `Alt` on macOS can serve as a more direct "Mod" equivalent to reduce mental context switching.
- **Bootstrapping:** We will ensure OmniWM starts *after* Kanata is ready to avoid "un-remapped" keys being sent to the WM during the first few seconds of boot.
