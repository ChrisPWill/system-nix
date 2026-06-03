# Task: Install OmniWM & Prepare Fallback

**Objective:** Install OmniWM via Homebrew and ensure Aerospace remains available as a fallback.

## Steps

1.  **Modify `modules/darwin/darwin-shared.nix`**:
    - Add `"BarutSRB/tap"` to `homebrew.taps`.
    - Add `"omniwm"` to `homebrew.casks`.
    - Verify `"aerospace"` remains in `homebrew.casks`.
2.  **macOS System Settings**:
    - **Requirement:** Programmatically set `system.defaults.spaces.spans-displays = true;` in `darwin-shared.nix` (which corresponds to turning **OFF** "Displays have separate Spaces" in System Settings).
    - This is required for OmniWM's multi-monitor workspace management to function correctly.
    - **Note:** This will break the Aerospace fallback while active, as Aerospace requires separate spaces.
3.  **Disable Sketchybar on macOS**:
    - Locate where Sketchybar is enabled for Darwin (likely `modules/home/desktop/wm/sketchybar/default.nix` or similar).
    - Add a conditional or comment out the service enablement for `stdenv.isDarwin` to prevent it starting during the migration.
4.  **Run `drs`**:
    - Apply the changes using `darwin-rebuild switch --flake .`.
