# Task: Port Kanata (Global Leader) to macOS

**Objective:** Get the Kanata Global Leader working on macOS to provide the consistent `Caps Lock -> Cmd+Alt` (Mod) and `Double-Tap Caps Lock -> Cmd+Alt+Shift` (Leader) layers.

## Steps

1.  **Configure macOS Kanata Service**:
    - Implement a manual `launchd.daemons.kanata` in `hosts/cwilliams-work-laptop/darwin-configuration.nix`.
    - Ensure it runs as `root` to access input devices.
2.  **Abstract Kanata configuration**:
    - Move the `kanata.nix` logic from `modules/nixos/graphical-environment/kanata.nix` into a shared module.
3.  **Apply configuration to Darwin**:
    - Enable the service in the host configuration.
    - Fetch `Karabiner-DriverKit-VirtualHIDDevice-6.2.0.pkg` from pinned upstream commit `c7df2059a84162d3d2d6784bebc887e888059375` with a fixed Nix hash.
    - Install the pinned package during nix-darwin activation when the package receipt is missing or not version `6.2.0`.
    - Configure launchd daemons for `Karabiner-VirtualHIDDevice-Manager activate` and `Karabiner-VirtualHIDDevice-Daemon`.
    - **Conflict Resolution:** Set `system.keyboard.enableKeyMapping = false` and `system.keyboard.remapCapsLockToEscape = false` in `darwin-shared.nix`.
    - **Manual Step:** Approve and activate the Karabiner VirtualHID system extension in _System Settings > Privacy & Security_ after installing the package.
    - **Manual Step:** Manually grant **Input Monitoring** and **Accessibility** permissions to the `kanata` binary in _System Settings > Privacy & Security_.
    - **Manual Step:** Ensure Karabiner-Elements itself is not running; Kanata only needs the standalone VirtualHID driver and daemon.
4.  **Test**:
    - Verify that holding Caps Lock and pressing `h` sends `Cmd+Alt+H`.
    - Verify that double-tapping and holding Caps Lock and pressing `h` sends `Cmd+Alt+Shift+H`.

## Planned Kanata Configuration

```lisp
(defalias
  ;; Modifiers
  m (multi lmet lalt)
  ms (multi lmet lalt lsft)

  ;; Tap: Esc, Hold: Cmd+Alt, Double-Tap Hold: Cmd+Alt+Shift
  lead (tap-dance 200 (
    (tap-hold 200 200 esc @m)
    (tap-hold 200 200 esc @ms)
  ))
)

(defsrc
  caps
)

(deflayer base
  @lead
)
```

## Planned Top-Level Actions (via skhd)

These are triggered by holding `Caps Lock` (`Cmd+Alt`):

- `cmd + alt - t` -> Open Terminal
- `cmd + alt - backslash` -> `toggle-pinned logseq`
- `cmd + alt - o` -> `toggle-pinned obsidian`
- `cmd + alt - m` -> Focus Monitor (internal logic)

## Improvement Opportunities

- **Readability:** Refactor `kanata.nix` to use clearer `defalias` and `deflayer` blocks.
