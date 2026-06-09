# Plan: Desktop And Graphical NixOS Consolidation

**Priority:** 4

**Objective:** Bring Linux/Niri graphical Home Manager configuration closer to the `desktop` domain while preserving the existing `graphical-nixos` module as a compatibility wrapper.

## Rationale

The current split is mostly platform-driven:

- `desktop/wm` contains Darwin OmniWM, skhd, sketchybar, and shared keybinds.
- `graphical-nixos` contains Linux/Niri, Dank Material Shell, portals, default apps, and MIME defaults.

The intent is the same: graphical desktop behavior. Niri already imports shared window-manager keybinds from `desktop/wm`, so the conceptual model is cross-platform desktop configuration rather than separate top-level domains.

## Proposed Layout

```text
modules/home/desktop/
  apps/
    communication.nix
    mime-defaults.nix
  terminals/
  wm/
    shared-keybinds.nix
    macos/
      omniwm/
      skhd/
      sketchybar/
    linux/
      niri/
      dank-material-shell/
```

## Compatibility Strategy

Keep `modules/home/graphical-nixos/default.nix` for existing host imports, but make it a thin wrapper around the new desktop modules.

Example:

```nix
{...}: {
  imports = [
    ../desktop/wm/linux/niri
    ../desktop/wm/linux/dank-material-shell
    ../desktop/apps/mime-defaults.nix
  ];
}
```

## Implementation Steps

1.  Move Niri files under `desktop/wm/linux/niri`.
2.  Move Dank Material Shell user configuration under `desktop/wm/linux/dank-material-shell`.
3.  Move Linux MIME defaults under `desktop/apps/mime-defaults.nix`.
4.  Keep `graphical-nixos/default.nix` as a wrapper.
5.  Update `homeModuleDir` path references for out-of-store symlinks.
6.  Update host-specific paths that reference `graphical-nixos/niri`.

## Success Criteria

- Graphical desktop behavior is discoverable under `desktop`.
- Existing host imports of `homeModules.graphical-nixos` continue to work.
- Shared keybinds remain shared between Niri and OmniWM.
- Niri, Dank Material Shell, portals, and MIME defaults still evaluate on the Linux host.
