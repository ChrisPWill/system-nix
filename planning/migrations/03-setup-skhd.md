# Task: Setup skhd for OmniWM Control

**Objective:** Use `skhd` to bind the Kanata-emitted `Cmd+Alt` (Mod) and `Cmd+Alt+Shift` (Leader) combinations to OmniWM commands.

## Steps
1.  **Install skhd**:
    - Add `"skhd"` to `homebrew.casks` in `modules/darwin/darwin-shared.nix`.
2.  **Configure skhd**:
    - Create `modules/home/desktop/wm/skhd/default.nix`.
    - Create `~/.config/skhd/skhdrc` using the standard `mod + mod - key : command` syntax.
3.  **De-couple OmniWM bindings**:
    - Ensure OmniWM's own config does not define these hotkeys to avoid conflicts.

## Planned Bindings (via skhd)

### Top-Level Actions (Caps Lock hold)
- `cmd + alt - t : open-terminal-at-cwd`
- `cmd + alt - backslash : toggle-pinned logseq`
- `cmd + alt - o : toggle-pinned obsidian`

### Window Management (Caps Lock hold)
- `cmd + alt - h : omniwmctl command focus left`
- `cmd + alt - j : omniwmctl command focus down`
- `cmd + alt - k : omniwmctl command focus up`
- `cmd + alt - l : omniwmctl command focus right`
- `cmd + alt - 1 : omniwmctl command switch-workspace 1`
... (and so on for 2-9)
- `cmd + alt - q : omniwmctl command switch-workspace Q`
- `cmd + alt - w : omniwmctl command switch-workspace W`
- `cmd + alt - e : omniwmctl command switch-workspace E`
- `cmd + alt - a : omniwmctl command switch-workspace A`
- `cmd + alt - s : omniwmctl command switch-workspace S`
- `cmd + alt - d : omniwmctl command switch-workspace D`

### Window Movement (Double-Tap Caps Lock hold OR Caps Lock + Shift)
- `cmd + alt + shift - h : omniwmctl command move left`
- `cmd + alt + shift - j : omniwmctl command move down`
- `cmd + alt + shift - k : omniwmctl command move up`
- `cmd + alt + shift - l : omniwmctl command move right`
- `cmd + alt + shift - 1 : omniwmctl command move-to-workspace 1`
... (and so on for 2-9)
- `cmd + alt + shift - q : omniwmctl command move-to-workspace Q`
- `cmd + alt + shift - w : omniwmctl command move-to-workspace W`
- `cmd + alt + shift - e : omniwmctl command move-to-workspace E`
- `cmd + alt + shift - a : omniwmctl command move-to-workspace A`
- `cmd + alt + shift - s : omniwmctl command move-to-workspace S`
- `cmd + alt + shift - d : omniwmctl command move-to-workspace D`

### Workspace & Monitor Management
- `cmd + alt + ctrl - h : omniwmctl command focus-monitor prev`
- `cmd + alt + ctrl - l : omniwmctl command focus-monitor next`
- `cmd + alt + shift + ctrl - h : omniwmctl command swap-workspace-with-monitor left`
- `cmd + alt + shift + ctrl - l : omniwmctl command swap-workspace-with-monitor right`

### Media & System
- `fn - f10 : osascript -e "set volume output muted not (output muted of (get volume settings))"`
- `fn - f11 : osascript -e "set volume output volume (output volume of (get volume settings) - 5)"`
- `fn - f12 : osascript -e "set volume output volume (output volume of (get volume settings) + 5)"`

## Improvement Opportunities
- **Shortcut Cleanup:** Identify and disable macOS system shortcuts (like Spotlight or `Cmd+Alt+H` Hide Others) that conflict with the new bindings.
