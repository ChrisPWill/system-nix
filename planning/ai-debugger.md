# Plan: AI Terminal Debugger

**Objective:** Provide instant AI-powered explanations and fixes for terminal errors, triggered by a global hotkey.

## Core Requirements
- **Global Leader:** Triggered via `leader + d` (Debug).
- **Output Capture:** Capture the last 50 lines of the currently focused terminal.
- **AI Analysis:** Send the captured text to an AI model (Gemini or local Ollama) with a specialized debugging prompt.
- **Floating Presentation:** Display the analysis and suggested fix in a small, floating terminal window.
- **Cross-Platform:** Works on both Linux (Niri) and macOS (OmniWM).

## Proposed Architecture
1.  **Trigger Mechanism:**
    - `leader + d` is mapped (via Kanata/skhd/Niri) to a specific keyboard combination (e.g., `Mod+Alt+Shift+D`).
    - The terminal (Ghostty) or a background service intercepts this to trigger the `ai-debug` script.
2.  **Capturing Output:**
    - *Challenge:* Standard WMs don't allow scraping text from windows.
    - *Solution:* If the terminal emulator (like Ghostty) doesn't provide a direct "get buffer" IPC yet, we will implement a shell-level "capture" mechanism or a script that the shell executes to grab its own scrollback/history if possible.
    - *Alternative:* Integrate with the shell's buffer (Zsh/Fish/Nu) via a hotkey that pipes the current screen state to the script.
3.  **The Debug Script (`ai-debug`):**
    - Takes the captured text.
    - Prompts: "I am a senior platform engineer. Analyze the following terminal output for errors, explain why it happened, and provide a concise command to fix it."
    - Pipes to `gemini-cli` or `ollama`.

## Implementation Steps
### Phase 1: Capture & AI Logic
- Create `modules/home/scripts/ai-debug`.
- Implement logic to handle the AI request and format the output.
- Add dependencies (`gemini-cli`, `gum` for display).

### Phase 2: WM/Shell Integration
- **Kanata:** Map `d` in the `leader` layer to `Mod+Alt+Shift+D`.
- **Niri/skhd:** Bind the combination to spawn `ghostty -e ai-debug`.
- **Shells:** Explore using `ghostty +inspect` or a shell-specific "copy buffer" command to feed the script.

## Success Criteria
- Encountering a build error and pressing `leader + d` opens a window explaining the error.
- The window provides a "Fix" command that can be copied or executed.
- The experience is identical on the work laptop and the personal PC.
