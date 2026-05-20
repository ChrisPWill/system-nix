# Plan: Ghostty Configuration Sync

**Objective:** Achieve 1:1 visual and behavioral parity for the Ghostty terminal across Linux and macOS using a declarative Home Manager configuration.

## Core Requirements
- **Shared Config:** Use a single source of truth for themes, fonts, and keybindings.
- **Dynamic Font Size:** Allow for slight variations (e.g., larger font on high-DPI laptop vs. desktop) if needed, while keeping the font family identical.
- **Stylix Integration:** Ensure colors are injected via the system-wide Stylix theme.

## Proposed Architecture
1.  **Module:** `modules/home/desktop/terminals/ghostty/default.nix`
2.  **Logic:**
    - Use `xdg.configFile."ghostty/config".text` or `programs.ghostty.settings`.
    - Extract common settings (font-family, cursor style, padding) into a shared attribute set.

## Implementation Steps
1.  **Extract Current Config:** Locate the existing `ghostty.lua` or `config` and move it into the Nix module.
2.  **Inject Stylix:** Use `config.lib.stylix.colors` to set the background, foreground, and ANSI colors if the native Stylix module for Ghostty is insufficient.
3.  **Cross-Platform Keybindings:** Standardize `Mod+Enter` for new windows and `Mod+T` for tabs across both platforms.

## Success Criteria
- Opening Ghostty on macOS looks and feels identical to Linux.
- Changing a setting in `modules/home/desktop/terminals/ghostty/default.nix` updates both machines after a rebuild.
