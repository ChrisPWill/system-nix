# .system-nix

A comprehensive Nix-based system configuration managed using [numtide/blueprint](https://github.com/numtide/blueprint). It provides a structured approach for NixOS, nix-darwin, and Home Manager across multiple machines.

## Project Overview

- **Core Technologies:** Nix, NixOS, nix-darwin, Home Manager.
- **Framework:** `blueprint` (automatically handles flake outputs based on directory structure).
- **Version Control:** [Jujutsu (`jj`)](https://github.com/martinvonz/jj) is preferred.

### Building and Running

Common operations are aliased for ease of use across different shells (Zsh, Fish, Nushell).

| Command | Action | Description |
| :--- | :--- | :--- |
| `hms` | `home-manager switch --flake .` | Rebuild and activate Home Manager configuration. |
| `nrs` | `sudo nixos-rebuild switch --flake .` | Rebuild and activate NixOS configuration (Linux only). |
| `drs` | `sudo darwin-rebuild switch --flake .` | Rebuild and activate nix-darwin configuration (macOS only). |
| `nd <name>` | `nix develop .#<name>` | Enter a specific development shell (e.g., `nd node22`). |

## Installation

1. Clone to `$HOME/.system-nix`.
2. For WSL2/Home Manager standalone:
   ```zsh
   nix-shell -p home-manager --run "home-manager switch --extra-experimental-features nix-command --extra-experimental-features flakes --flake .#cwilliams@<hostname>"
   ```

# Custom Installer ISO

You can build a custom NixOS installer ISO that comes pre-configured with your system settings and contains this configuration flake.

## Build the ISO

```bash
nix build .#nixosConfigurations.installer.config.system.build.isoImage
```

The resulting ISO will be in `result/iso/`.

## Testing with a VM

You can test the entire installation process using QEMU:

1.  Run the test script:
    ```bash
    ./modules/home/scripts/test-iso-vm
    ```

# Directory Structure

- `hosts/<hostname>/`: Entry points for each machine.
- `modules/home/programs/<program>/`: Program-specific Nix modules and configs.
- `modules/home/home-shared.nix`: Universal Home Manager user settings.
- `modules/nixos/` & `modules/darwin/`: System-level modules.
- `modules/theming/`: Shared styling.
