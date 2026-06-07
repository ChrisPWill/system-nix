# Plan: OmniWM Config Extraction

**Objective:** Split the OmniWM Home Manager module into smaller data and generator pieces so app rules, workspaces, and settings are easier to maintain.

## Core Requirements

- **Preserve Generated TOML:** The resulting `omniwm/settings.toml` should be behaviorally equivalent.
- **Keep Home Manager Ownership:** Continue generating the config through `xdg.configFile`.
- **Data First:** App rules and workspace definitions should be easy to scan and edit without reading all settings.
- **No Hotkey Regression:** Preserve integration with shared skhd/OmniWM keybindings.

## Proposed Architecture

1.  **Data Files:**
    - `modules/home/desktop/wm/omniwm/app-rules.nix`
    - `modules/home/desktop/wm/omniwm/workspaces.nix`
    - Optional `modules/home/desktop/wm/omniwm/settings.nix`
2.  **Library Helpers:**
    - Keep helper constructors such as `appRule`, `workspace`, and color conversion in a small local lib expression.
3.  **Default Module:**
    - Keep `default.nix` as the orchestrator that imports data, assembles the settings attrset, and writes TOML.
4.  **Future Option Surface:**
    - If useful, expose `home.desktop.wm.omniwm.appRules` and `home.desktop.wm.omniwm.workspaces` options for host-specific overrides.

## Implementation Steps

1.  Extract app rules into a dedicated Nix file.
2.  Extract workspace definitions into a dedicated Nix file.
3.  Move reusable helper functions into a local `lib.nix` if extraction would otherwise duplicate logic.
4.  Keep the final TOML generation in `default.nix`.
5.  Compare generated TOML before and after the refactor.

## Success Criteria

- `omniwm/default.nix` becomes an orchestrator rather than a large mixed data file.
- Generated settings are equivalent before and after the extraction.
- Adding an app rule no longer requires navigating the whole OmniWM settings module.
- The Darwin system flake target still builds, for example `.#darwinConfigurations.cwilliams-work-laptop.system`.
