# Task: Cleanup Aerospace Fallback

**Objective:** Finalize the migration by removing the old window manager.

## Steps
1.  **Remove Aerospace**:
    - Delete `"aerospace"` from `homebrew.casks` in `modules/darwin/darwin-shared.nix`.
    - Delete `"nikitabobko/tap"` from `homebrew.taps`.
2.  **Remove Config**:
    - Delete `modules/home/desktop/wm/aerospace/`.
    - Remove the import in `modules/home/desktop/default.nix`.
3.  **Clean up symlinks**:
    - Ensure `~/.aerospace.toml` is removed.
4.  **Move migration plan to completed**:
    - After implementation and verification, move this file to `planning/migrations/completed/`.

## Success Criteria
- Aerospace is completely removed from the system and Nix configuration.
