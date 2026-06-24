# Plan: "DevDoc" Screenshot Pipeline

**Objective:** Create a zero-friction pipeline for capturing screenshots, optimizing them, and making them immediately available for LogSeq documentation, with automatic routing to the correct graph.

## Core Requirements

- **Global Leader:** Triggered via `leader + p` (Capture to **P**ipeline).
- **Capture:** Trigger a region-select screenshot using native tools (macOS `screencapture`, Linux `grim` or `slurp`).
- **Graph Detection:**
  - If `isWorkMachine`: Default to `~/Notes/work/assets/`.
  - Else: Default to `~/Notes/personal/assets/`.
- **Optimize:** Automatically compress the image to save space (using `pngquant` or `oxipng`).
- **Store:** Move the optimized image into the detected LogSeq `assets/` directory with a timestamped name.
- **Link:** Place the markdown-formatted link (e.g., `![[screenshot_20260520_1430.png]]`) into the clipboard.

## Proposed Architecture

1.  **Script:** `modules/home/scripts/devdoc-capture` (Nushell).
    - Use environment variables or flags passed from Nix to determine the graph root.
    - Detect OS to use the correct capture tool.
    - Execute the capture, optimize, move, and copy steps sequentially.
2.  **Dependencies:** Ensure `pngquant` and a clipboard utility (`wl-copy` for Linux, `pbcopy` for macOS) are available in `home.packages`.

## Implementation Steps

1.  **Create Script:**
    - Handle macOS: `screencapture -i $tmp_path` -> `pngquant` -> move -> `pbcopy`.
    - Handle Linux: `grim -g (slurp) $tmp_path` -> `pngquant` -> move -> `wl-copy`.
2.  **Nix Integration:**
    - Pass the target LogSeq path to the script or set an environment variable based on `config.isWorkMachine`.
3.  **WM Integration:**
    - **OmniWM/skhd:** Bind `cmd + alt + shift - p` to execute `devdoc-capture`.
    - **Niri:** Bind `Mod+Alt+Shift+P` to execute `devdoc-capture`.
    - **Kanata:** Map `p` in the `leader` layer to send the combination.

## Success Criteria

- Pressing `leader + p` on a work laptop saves to the work graph.
- Pressing `leader + p` on a personal PC saves to the personal graph.
- Pasting immediately outputs the correct `![[...]]` markdown link.
