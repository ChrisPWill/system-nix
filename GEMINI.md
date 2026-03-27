# .system-nix

Modular Nix system configuration managed with [numtide/blueprint](https://github.com/numtide/blueprint) for NixOS, nix-darwin, and Home Manager.

## Quick Reference
| Alias | Action |
| :--- | :--- |
| `hms` | `home-manager switch --flake .` |
| `nrs` | `sudo nixos-rebuild switch --flake .` (Linux) |
| `drs` | `sudo darwin-rebuild switch --flake .` (macOS) |
| `nd <name>` | `nix develop .#<name>` |

## Development Conventions

- **Hybrid Philosophy (Neovim & Helix):**
    - **Philosophy:** Neovim (`meow`) uses Helix-inspired navigation (`g` prefix) and selection modes while retaining its native "Verb-Noun" model.
    - **LSP & Tooling Parity:** Both editors share a unified LSP/formatter ecosystem (e.g., `nixd`, `basedpyright`, `ruff`, `rust-analyzer`).
    - **UI Alignment:** Visuals (Relative lines, cursor shapes, theme) are synchronized for zero-friction switching.
    - **Home Manager Architecture:** Configuration is organized using a domain-driven structure (Intent over Syntax). See `modules/home/README.md` for architecture details.
    - **Reference:** See `modules/home/dev/editors/neovim/README.md` and `modules/home/dev/editors/helix/README.md`.
- **Knowledge Base:** Maintain reference guides in `modules/home/dev/editors/neovim/docs/`. Keep `cheatsheet.md` as the primary entry point.
- **Blueprint Structure:** Files in `hosts/` are entry points; `modules/` are shared components. High-iteration files (e.g., `wezterm.lua`) use `mkOutOfStoreSymlink` for immediate testing.
- **Workflow:** Jujutsu (`jj`) is preferred for version control. Use `jj st` for status.

## Directory Highlights
- `hosts/<hostname>/`: Machine entry points.
- `modules/home/<domain>/`: Functional domains for user configuration (see `modules/home/README.md`).
- `modules/home/home-shared.nix`: Universal Home Manager user settings.
- `modules/theming/`: Shared styling and custom theme options.

*For detailed installation instructions and framework details, see the root `README.md`.*
