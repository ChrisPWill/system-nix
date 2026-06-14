# .system-nix

Modular Nix system configuration managed with [numtide/blueprint](https://github.com/numtide/blueprint) for NixOS, nix-darwin, and Home Manager.

## Quick Reference

| Alias       | Action                                                        |
| :---------- | :------------------------------------------------------------ |
| `sw`        | Preferred smart switch via `nh` using this flake/current host |
| `hms`       | Deprecated compatibility command for `nh home switch`         |
| `nrs`       | Deprecated compatibility command for `nh os switch`           |
| `drs`       | Deprecated compatibility command for `nh darwin switch`       |
| `nd <name>` | `nix develop .#<name>`                                        |

## Global Leader

The system implements a **Global Leader** capability using **Kanata** for keyboard layers, with platform window-manager bindings handled by **skhd/OmniWM** on macOS and **Niri** on NixOS.

- **Caps Lock** acts as the Global Leader:
  - **Tap:** Sends `Esc`.
  - **Hold:** Activates the primary window-manager layer as **`Win/Cmd+Alt`**.
  - **Double-tap hold:** Activates the shifted layer as **`Win/Cmd+Alt+Shift`**.
- This allows for consistent, mnemonic, system-wide hotkeys that can be configured in both Kanata (at the hardware level) and the platform window manager.
- **Note:** New global leader hotkeys must be bound in the platform window-manager config after Kanata emits the shared modifier chord.

## Development Conventions

- **Hybrid Philosophy (Neovim & Helix):**
  - **Philosophy:** Neovim (`meow`) uses Helix-inspired navigation (`g` prefix) and selection modes while retaining its native "Verb-Noun" model.
  - **Agent Note:** Assume Helix-style navigation (e.g., `gh` for line start, `gl` for line end) even in Neovim. Avoid suggesting standard Vim motions that conflict with these overrides.
  - **LSP & Tooling Parity:** Both editors share a unified LSP/formatter ecosystem (e.g., `nixd`, `basedpyright`, `ruff`, `rust-analyzer`).
  - **UI Alignment:** Visuals (Relative lines, cursor shapes, theme) are synchronized for zero-friction switching.
  - **Home Manager Architecture:** Configuration is organized using a domain-driven structure (Intent over Syntax). See `modules/home/README.md` for architecture details.
  - **Reference:** See `modules/home/dev/editors/neovim/README.md` and `modules/home/dev/editors/helix/README.md`.

- **Architecture & Contribution Rules:**
  - **Intent over Syntax:** Group tools by their functional role (e.g., `dev/`, `ops/`, `knowledge`), not by whether they are "packages" or "programs".
  - **Encapsulation:** Tool-specific logic (aliases, init scripts, plugins) must live within the tool's domain module, not in global shared files.
  - **Gating Pattern:** Machine-specific tools should be placed in the correct functional domain but wrapped in a conditional block:
    ```nix
    home.packages = lib.optionals config.isPersonalMachine [ pkgs.discord ];
    ```
  - **Orchestration:** High-level files like `home-shared.nix` should only import Domain Orchestrators (`./dev`, `./ops`), never individual tool modules.

- **Standard Workflows:**
  - **Adding a Tool:**
    1. Identify the functional domain (Intent).
    2. Create `modules/home/<domain>/<tool>.nix`.
    3. Define `home.packages` and/or `programs.<name>`.
    4. Add `./<tool>.nix` to `modules/home/<domain>/default.nix`.
  - **Knowledge Base:** Maintain reference guides in `modules/home/dev/editors/neovim/docs/`. Keep `cheatsheet.md` as the primary entry point.
- **Blueprint Structure:** Files in `hosts/` are entry points; `modules/` are shared components. High-iteration files (e.g., `wezterm.lua`) use `mkOutOfStoreSymlink` for immediate testing.
- **Workflow:** Jujutsu (`jj`) is preferred for version control. Use `jj st` for status.

## Directory Highlights

- `hosts/<hostname>/`: Machine entry points.
- `modules/home/<domain>/`: Functional domains for user configuration (see `modules/home/README.md`).
- `modules/home/home-shared.nix`: Universal Home Manager user settings.
- `modules/theming/`: Shared styling and custom theme options.
- `SECRETS.md`: Guide for managing and using encrypted secrets with sops-nix.

For detailed installation instructions and framework details, see the root `README.md`.
