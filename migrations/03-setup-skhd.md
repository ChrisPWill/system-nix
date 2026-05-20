# Task: Setup skhd for OmniWM Control

**Objective:** Use `skhd` to bind the Kanata-emitted combinations to OmniWM commands.

## Steps
1.  **Install skhd**:
    - Add `"skhd"` to `homebrew.casks` in `modules/darwin/darwin-shared.nix`.
2.  **Configure skhd**:
    - Create `modules/home/desktop/wm/skhd/default.nix`.
    - Create `~/.config/skhd/skhdrc` containing bindings like:
      `alt + shift + ctrl + h : omniwmctl focus-window left` (adjust for Global Leader combos).
3.  **De-couple OmniWM bindings**:
    - Ensure OmniWM's own config does not define these hotkeys to avoid conflicts.

## Planned Bindings (via skhd)
Using `skhd` allows us to intercept the Global Leader's `Mod+Alt+Shift` and standard `Mod` combos:

### Global Leader (intercepted from Kanata)
- `cmd + alt + shift - t : open-terminal-at-cwd`
- `cmd + alt + shift - l : open -a LogSeq`
- `cmd + alt + shift - o : open -a Obsidian`

### Window Management (via skhd)
Using `alt` (Option) as the primary modifier to avoid `cmd` conflicts:
- `alt - h : omniwmctl focus-window left`
- `alt - j : omniwmctl focus-window down`
- `alt - k : omniwmctl focus-window up`
- `alt - l : omniwmctl focus-window right`
- `alt + shift - h : omniwmctl move-window left`
- `alt + shift - j : omniwmctl move-window down`
- `alt + shift - k : omniwmctl move-window up`
- `alt + shift - l : omniwmctl move-window right`
- `alt - 1 : omniwmctl focus-workspace 1`
... (and so on for 2-9)
- `alt + shift - 1 : omniwmctl command move-to-workspace 1`

### Workspace & Monitor Management
- `alt + ctrl + shift - h : omniwmctl command swap-workspace-with-monitor left`
- `alt + ctrl + shift - l : omniwmctl command swap-workspace-with-monitor right`
- `alt + ctrl - h : omniwmctl command focus-monitor left`
- `alt + ctrl - l : omniwmctl command focus-monitor right`

### Media & System (Consistency with Niri)
- `fn - f10 : osascript -e "set volume output muted not (output muted of (get volume settings))"` (Mute)
- `fn - f11 : osascript -e "set volume output volume (output volume of (get volume settings) - 5)"` (Volume Down)
- `fn - f12 : osascript -e "set volume output volume (output volume of (get volume settings) + 5)"` (Volume Up)

## Improvement Opportunities
- **Shortcut Cleanup:** As part of this task, identify and disable macOS system shortcuts (like Spotlight or Raycast) that conflict with the new `alt` or `cmd+alt+shift` bindings.
- **Decoupling:** By moving app launchers (Ghostty, etc.) to `skhd`, we make the WM interchangeable. If we ever switch back from OmniWM, the launchers remain functional.
- **Helix Alignment:** Ensure that `mod + g` prefixes (if used) follow the Helix-style navigation mentioned in `GEMINI.md`.
