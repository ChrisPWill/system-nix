# CLI Tools & Shell Hotkeys

This module configures modern CLI utilities and interactive shell enhancements.

## 󰌌 Global Shell Hotkeys

These hotkeys are available across all interactive shells (Fish, Zsh, Nushell).

| Key      | Action                    | Description                                                    |
| :------- | :------------------------ | :------------------------------------------------------------- |
| `Alt-o`  | **Television (tv-nvim)**  | Launch the Television file picker (integrated with Neovim).    |
| `Alt-w`  | **Viddy (Watch Command)** | Wrap the current command line in `viddy` and execute it.       |
| `Ctrl-r` | **Atuin Search**          | Search shell history using Atuin.                              |
| `Ctrl-t` | **Smart Autocomplete**    | Television-powered smart autocomplete for the current context. |

## 󰘦 Modern Unix Tools

We use a selection of modern alternatives to classic Unix commands:

- **`viddy`**: A modern `watch` replacement with history and diffing.
- **`eza`**: A modern replacement for `ls`.
- **`bat`**: A `cat` clone with syntax highlighting and Git integration.
- **`fd`**: A simple, fast and user-friendly alternative to `find`.
- **`ripgrep` (rg)**: An extremely fast alternative to `grep`.
- **`atuin`**: A replacement for shell history with a SQLite backend.
- **`procs`**: A modern replacement for `ps`.
