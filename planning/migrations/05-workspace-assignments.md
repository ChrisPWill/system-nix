# Task: Workspace-Monitor Persistence

**Objective:** Port the workspace-to-monitor assignments from Aerospace to OmniWM to maintain a consistent multi-monitor workflow.

## Logic to Port (from `aerospace.toml`)
- **Main Monitor:** Workspaces `1`, `2`, `3`, `4`, `5`, `6`, `7`, `8`, `9`.
- **Built-in Monitor:** Workspaces `Q`, `W`, `E`, `A`, `S`, `D`.

## Steps
1.  **Identify OmniWM Assignment Syntax**:
    - Use `omniwmctl` or `settings.toml` to force workspace assignment to specific displays.
2.  **Update `modules/home/desktop/wm/omniwm/default.nix`**:
    - Add the rules to the `settings.toml` generation.
    - Ensure names/IDs for monitors are dynamically detected or matched by common patterns (e.g., "built-in").
3.  **Move migration plan to completed**:
    - After implementation and verification, move this file to `planning/migrations/completed/`.

## Improvement Opportunities
- **Consistency:** Align the "Main" monitor workspaces with how Niri handles multiple outputs on Linux.

## Success Criteria
- Opening workspace `Q` always appears on the laptop screen.
- Opening workspace `1` always appears on the external (main) monitor.
