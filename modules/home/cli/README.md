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

## 󰣇 Cross-Platform Command Names (Fish)

`os-compat.nix` defines Fish abbreviations so familiar command names work on the
other platform. They are abbreviations, not aliases: the real command expands in
place at the prompt, because these pairs share a name but not a flag set.

### On macOS (Linux names → macOS equivalents)

| Abbreviation                     | Expands to                                                      |
| :------------------------------- | :-------------------------------------------------------------- |
| `xdg-open`                       | `open`                                                          |
| `lsblk`                          | `diskutil list`                                                 |
| `port`                           | `lsof -nP -iTCP:<port> -sTCP:LISTEN` (cursor lands on the port) |
| `flushdns`                       | `dscacheutil -flushcache` plus an mDNSResponder restart         |
| `ss`                             | `lsof -iTCP -sTCP:LISTEN -n -P`                                 |
| `xclip` / `xclip-o`              | `pbcopy` / `pbpaste`                                            |
| `free`                           | `memory_pressure`                                               |
| `journalctl`                     | `log show --last 1h`                                            |
| `journalctl-f`                   | `log stream --level info`                                       |
| `locate`                         | `mdfind -name`                                                  |
| `ldd`                            | `otool -L`                                                      |
| `lshw` / `dmidecode`             | `system_profiler SPHardwareDataType`                            |
| `sleepnow` / `systemctl-suspend` | `pmset sleepnow`                                                |
| `sensors` / `powertop`           | `macmon`                                                        |

Suspend is not bound to `suspend`, which would shadow Fish's builtin of that name.

### On Linux (macOS names → Linux equivalents)

| Abbreviation | Expands to |
| :----------- | :--------- |
| `open`       | `xdg-open` |
| `pbcopy`     | `wl-copy`  |
| `pbpaste`    | `wl-paste` |

Clipboard access assumes Wayland, matching the only graphical Linux host.
