# Task: Re-integrate Sketchybar

**Objective:** Adapt Sketchybar to work with OmniWM.

## Steps
1.  **Re-enable Sketchybar**:
    - Restore the Sketchybar service enablement for Darwin.
2.  **Update Event Logic**:
    - Modify `modules/home/desktop/wm/sketchybar/sketchybar.sh` and associated scripts.
    - Replace `aerospace` CLI calls with `omniwmctl` calls.
    - Update event subscriptions to use OmniWM's IPC if available, or fall back to generic shell-based polling/triggers.

## Success Criteria
- Sketchybar correctly displays the active OmniWM workspace.
- Window titles and icons update as focus changes in OmniWM.
