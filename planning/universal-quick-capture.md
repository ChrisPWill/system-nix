# Plan: Universal Quick-Capture for LogSeq

**Objective:** Create a unified, cross-platform mechanism for capturing notes/tasks directly into LogSeq from anywhere in the system using the Global Leader.

## Core Requirements

- **Cross-Platform:** Must work on Linux (Niri) and macOS (OmniWM).
- **Global Access:** Triggered by `leader + n` (handled by Kanata -> skhd/niri).
- **Minimal Friction:** Uses `gum input` in a small, floating terminal.
- **Backend:** Appends to the daily LogSeq journal file.

## Proposed Architecture

1.  **Logic:** A Nushell script (`modules/home/scripts/quick-capture`) that:
    - Resolves the LogSeq journal path (e.g., `~/Notes/journals/2026_05_20.md`).
    - Prompts the user using `gum input`.
    - Appends the text as a LogSeq block (e.g., `- 14:30: [Captured Text]`).
2.  **Input UI:**
    - A dedicated terminal command that spawns the script in a focused, floating window.
    - Uses `gum` for a clean, minimal interface.
3.  **WM Integration:**
    - **Linux (Niri):** `niri msg action spawn -- floating-terminal quick-capture`
    - **macOS (skhd/OmniWM):** `skhd -c "ghostty -e quick-capture"` (with an OmniWM rule to float/center the "quick-capture" window).

## Implementation Steps

### Phase 1: The Capture Script

- Create `modules/home/scripts/quick-capture`.
- Implement path resolution for LogSeq journals (handling the `YYYY_MM_DD.md` format).
- Use `gum input --placeholder "Capture note..."` to gather text.

### Phase 2: WM Rules & Hotkeys

- **OmniWM:** Add a window rule for `app == "quick-capture"` to float and center.
- **Niri:** Add a similar rule in `windowrules.kdl`.
- **Kanata:** Map `n` in the `leader` layer to `Mod+Alt+Shift+N`.
- **skhd/Niri:** Map the hotkey to spawn the capture terminal.

## Success Criteria

- Pressing `leader + n` on either OS opens a minimal terminal prompt.
- Typing a note and hitting Enter appends it to today's LogSeq journal.
- The window closes automatically upon completion.
