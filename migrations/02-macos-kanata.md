# Task: Port Kanata (Global Leader) to macOS

**Objective:** Get the Kanata Global Leader working on macOS to provide the consistent `Caps Lock -> Mod+Alt+Shift` layer.

## Steps
1.  **Find the macOS Kanata service**:
    - Research if `nix-darwin` has a built-in `services.kanata` or if a Homebrew formula is better suited.
2.  **Abstract Kanata configuration**:
    - If possible, move the `kanata.nix` logic from `modules/nixos/graphical-environment/kanata.nix` into a shared module or extract the configuration string.
3.  **Apply configuration to Darwin**:
    - Enable the service in `hosts/cwilliams-work-laptop/darwin-configuration.nix` or `modules/darwin/darwin-shared.nix`.
    - **Conflict Resolution:** Set `system.keyboard.enableKeyMapping = false` and `system.keyboard.remapCapsLockToEscape = false` in `darwin-shared.nix`. This ensures `nix-darwin` doesn't fight Kanata for control of the Caps Lock key.
4.  **Test**:
    - Verify that holding Caps Lock and pressing a mapped key sends the intended `Mod+Alt+Shift` combination on macOS.

## Planned Kanata Layers (Consistent with Linux)
The goal is to mirror the Niri Global Leader setup:
- **Base Layer:**
  - `Caps Lock` -> `tap: Esc`, `hold: leader-layer`
- **Leader Layer (Mod+Alt+Shift):**
  - `t` -> `Mod+Alt+Shift+T` (Open Terminal at CWD)
  - `l` -> `Mod+Alt+Shift+L` (Toggle LogSeq)
  - `o` -> `Mod+Alt+Shift+O` (Toggle Obsidian)
  - `m` -> `layer-toggle: monitor`

## Improvement Opportunities
- **Readability:** The current `kanata.nix` is noted as "badly needs to be updated to be more readable". We will refactor the macOS version to use clearer `defalias` and `deflayer` blocks.
- **Cross-Platform Scripting:** The `toggle-pinned` script (`modules/home/scripts/toggle-pinned`) currently relies on `niri msg`. We will refactor it to detect the environment and use `omniwmctl query` on macOS. Since both tools output JSON, we can maintain a unified Nushell logic for window management across both OSs.
- **Latency:** We will verify if `--nodelay` is sufficient on Darwin or if `interception-tools` style low-level access is required for optimal feel.
