# .system-nix

This project is a comprehensive Nix-based system configuration (dotfiles) managed using [numtide/blueprint](https://github.com/numtide/blueprint). It provides a structured and modular approach to managing NixOS, nix-darwin, and Home Manager configurations across multiple machines.

## Project Overview

- **Core Technologies:** Nix, NixOS, nix-darwin, Home Manager.
- **Framework:** `blueprint` (automatically handles flake outputs based on directory structure).
- **Version Control:** [Jujutsu (`jj`)](https://github.com/martinvonz/jj) is preferred, but Git is also compatible.
- **Architecture:** 
    - `hosts/`: Host-specific configurations (NixOS, Darwin, or standalone Home Manager).
    - `modules/`: Modularized configuration components shared across systems.
    - `devshells/`: Pre-configured development environments.
    - `templates/`: Nix flake templates for bootstrapping new projects.

## Key Hosts

- **cwilliams-laptop**: NixOS system (x86_64-linux).
- **cwilliams-work-laptop**: macOS system using nix-darwin (aarch64-darwin).
- **personal-pc-win**: Standalone Home Manager configuration (likely for WSL or Linux).

## Building and Running

Common operations are aliased for ease of use across different shells (Zsh, Fish, Nushell).

| Command | Action | Description |
| :--- | :--- | :--- |
| `hms` | `home-manager switch --flake .` | Rebuild and activate Home Manager configuration. |
| `nrs` | `sudo nixos-rebuild switch --flake .` | Rebuild and activate NixOS configuration (Linux only). |
| `drs` | `sudo darwin-rebuild switch --flake .` | Rebuild and activate nix-darwin configuration (macOS only). |
| `nd <name>` | `nix develop .#<name>` | Enter a specific development shell (e.g., `nd node22`). |

### Initial Installation

1. Clone to `$HOME/.system-nix`.
2. For WSL2/Home Manager standalone:
   ```zsh
   nix-shell -p home-manager --run "home-manager switch --extra-experimental-features nix-command --extra-experimental-features flakes --flake .#cwilliams@<hostname>"
   ```

## Development Conventions

- **Blueprint Structure:**
    - Files in `hosts/` automatically become `nixosConfigurations`, `darwinConfigurations`, or `homeConfigurations`.
    - Files in `modules/` are available via `inputs.self.<type>Modules`.
- **Out-of-Store Symlinks:** High-iteration configuration files (like `wezterm.lua` or `aerospace.toml`) are often symlinked using `mkOutOfStoreSymlink` to allow immediate testing without a full Nix rebuild.
- **Tooling Preferences:**
    - **Shells:** `fish` (primary interactive), `zsh`, and `nushell` are all supported and configured.
    - **CLI Tools:** Heavy use of modern Rust-based tools: `eza` (ls), `bat` (cat), `fd` (find), `ripgrep` (grep), `zoxide` (cd), `yazi` (file manager), and `television` (fuzzy finder).
    - **Editor:** Helix and Neovim (meow).
    - **Neovim Architecture (meow):**
        - **Philosophy:** "Hybrid Philosophy" (Neovim Verb-Noun + Helix Navigation).
        - **Core Rules:** Retains operator-pending mode while adopting Helix `g` (Goto), `m` (Match/Surround), and Space (`<leader>`) modes.
        - **Framework:** Managed via `nixCats` with `lze` for high-performance lazy loading.
        - **Structure:** `modules/home/programs/neovim/`
            - `README.md`: Architectural overview and structural map.
            - `KEYMAPS.md`: Detailed mapping philosophy and logic.
            - `config/lua/plugins/`: Domain-specific plugin specifications (UI, LSP, Coding, etc.).
            - `config/lua/keymaps.lua`: Global hybrid keybindings.
            - `docs/`: Personal Knowledge Base (Markdown reference guides and KEYMAPS.md).

- **Knowledge Base Maintenance:**
    - When adding new complex plugins or modifying significant workflows in Neovim, **ALWAYS** update or create a corresponding reference guide in `modules/home/programs/neovim/docs/`.
    - These guides should focus on practical use-cases, keybindings, and "how-to" scenarios to ensure the configuration remains self-documenting and accessible across different machines.

- **Jujutsu Workflow:** This repository uses `.jj/` for version control. Use `jj st` for status and `jj commit` (or automatic snapshots) for changes.

## Directory Structure Highlights

- `hosts/<hostname>/`: Entry points for each machine.
- `modules/home/programs/<program>/`: Program-specific Nix modules and their corresponding (non-Nix) configuration files.
- `modules/home/home-shared.nix`: Universal Home Manager user settings.
- `modules/nixos/` & `modules/darwin/`: System-level modules for Linux and macOS respectively.
- `modules/theming/`: Shared styling (likely utilizing Stylix).
- `templates/`: Useful for starting new projects with `nix flake init -t .#<template>`.
