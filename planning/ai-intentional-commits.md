# Plan: AI-Powered "Intentional Commits" (Shell Integration)

**Objective:** Streamline the commit process by generating high-quality, context-aware commit messages using AI, supporting both Jujutsu (`jj`) and Git, triggered via a shell hotkey.

## Core Requirements
- **VCS Detection:** Automatically detect if the current directory is a `jj` repo or a standard `git` repo.
- **Context Generation:** Feed the current diff and/or status into an AI model (Gemini or local Ollama).
- **Interactive Selection:** Present 3 suggested messages using a TUI (e.g., `gum`).
- **One-Touch Application:** Update the `jj` description or perform a `git commit` with the chosen message.
- **Shell Hotkey:** Triggered via `Ctrl-g` (or similar) across Zsh, Fish, and Nushell.

## Proposed Architecture
1.  **Logic:** A Nushell script (`modules/home/scripts/ai-commit`).
    - **Detect Backend:** Check for `.jj/` or `.git/`.
    - **Get Diff:** Run `jj diff` or `git diff --cached` (if nothing cached, `git diff`).
    - **AI Call:** Pipe the diff to a specialized agent/prompt via `gemini-cli` or `ollama`.
    - **Pick & Apply:** Use `gum choose` to select the message.
2.  **Shell Integration Pattern:**
    - Mirror the `viddy` implementation found in `modules/home/core/shells/`.
    - **Fish:** `bind \cg 'ai-commit'`
    - **Nushell:** Add to `keybindings` in `nushell.nix`.
    - **Zsh:** Create a ZLE widget and bind to `^g`.

## Implementation Steps
1.  **Create Script:** `modules/home/scripts/ai-commit`.
    - Logic for backend detection and AI interaction.
2.  **Configure Shells:**
    - Update `modules/home/core/shells/fish.nix`.
    - Update `modules/home/core/shells/nushell.nix`.
    - Update `modules/home/core/shells/zsh.nix`.
3.  **Refine Prompting:** Ensure the AI knows to output 3 distinct, short commit message options.

## Success Criteria
- Pressing `Ctrl-g` in any shell within a `jj` repo generates suggestions and updates the description.
- Pressing `Ctrl-g` in a `git` repo generates suggestions and performs a commit.
- Works consistently across Linux and macOS.
