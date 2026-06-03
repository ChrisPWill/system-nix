# Task: Cross-Platform Scripting (toggle-pinned)

**Objective:** Refactor the `toggle-pinned` script to work on both Niri (Linux) and OmniWM (macOS).

## Current State

- Script: `modules/home/scripts/toggle-pinned`
- Language: Nushell (`nu`)
- Dependency: `niri msg` (JSON output)

## Proposed Architecture

We will use Nushell's native environment detection to switch between WM backends.

```nu
def get_wm_backend [] {
    if (which niri | is-not-empty) { "niri" }
    else if (which omniwmctl | is-not-empty) { "omniwm" }
    else { error make { msg: "No supported window manager detected" } }
}

def query_windows [backend: string] {
    if $backend == "niri" {
        niri msg --json windows | from json
    } else {
        omniwmctl query windows --json | from json
    }
}
# ... and so on for workspaces and actions
```

## Steps

1.  **Abstract `query_windows` and `query_workspaces`**:
    - Ensure field names (e.g., `app_id` vs `app`) are mapped to a consistent internal record.
2.  **Abstract Actions**:
    - Map `niri msg action move-window-to-workspace` to `omniwmctl command move-to-workspace`.
    - Map `move-window-to-floating` to OmniWM's equivalent.
3.  **Test on macOS**:
    - Verify `toggle-pinned` can pull/push LogSeq and Obsidian using the new OmniWM backend.
4.  **Move migration plan to completed**:
    - After implementation and verification, move this file to `planning/migrations/completed/`.

## Success Criteria

- The same `toggle-pinned` script works on both Linux and macOS.
- No breakage of existing Niri functionality.
