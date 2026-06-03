# Known Issues (OmniWM/Kanata macOS Migration)

This document tracks unresolved technical hurdles and pending refactors from the macOS window management migration.

## 1. AppleScript Dependency in `toggle-pinned`

- **Issue:** Window positioning and resizing on macOS currently rely on `osascript` (AppleScript), which is slow and fragile.
- **Status:** Technical Debt.
- **Proposed Fix:** Verify if `omniwmctl` CLI matures to support native `window move/resize` commands.

## 2. Workspace Name Resolution

- **Issue:** `omniwmctl` might not resolve `displayName` for commands like `switch-workspace`.
- **Status:** Workaround applied.
- **Current State:** `skhd` bindings use raw workspace numbers (e.g., `10` instead of `Q`) for laptop-bound workspaces.

## 3. System Shortcut Conflicts

- **Issue:** macOS global shortcuts (e.g., `Cmd+Alt+H`) conflict with window manager bindings.
- **Status:** Partial fix applied.
- **Action:** `darwin-shared.nix` now explicitly disables `30` (Hide Others) and `64` (Spotlight). Other conflicts may emerge.
