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
| `drs` | `darwin-rebuild switch --flake .` | Rebuild and activate nix-darwin configuration (macOS only). |
| `nd <name>` | `nix develop .#<name>` | Enter a specific development shell (e.g., `nd node22`). |

## Installation

Clone this repository to `$HOME/.system-nix`:
```bash
git clone https://github.com/cwilliams/.system-nix.git ~/.system-nix
# Or use jujutsu
jj git clone https://github.com/cwilliams/.system-nix.git ~/.system-nix
```

### NixOS
For a new installation, use the [Custom Installer ISO](#custom-installer-iso) or bootstrap from an existing NixOS system:
```bash
sudo nixos-rebuild switch --flake .#<hostname>
```

### MacOS (Darwin)
Ensure Nix is installed (recommended: [Determinate Systems Nix Installer](https://github.com/DeterminateSystems/nix-installer)), then run:
```bash
nix run nix-darwin -- switch --flake .#cwilliams-work-laptop
```
*Note: You may need to add `--extra-experimental-features "nix-command flakes"` if not already enabled.*

### WSL2 / Standalone Home Manager
Ensure Nix is installed (see [Official Installation Instructions](https://nixos.org/download/#nix-install-linux)), then activate on a fresh system:
```zsh
nix-shell -p home-manager --run "home-manager switch --extra-experimental-features nix-command --extra-experimental-features flakes --flake .#cwilliams@<hostname>"
```

# Custom Installer ISO

You can build a custom NixOS installer ISO that comes pre-configured with your system settings.

## Build the ISO
```bash
nix build .#nixosConfigurations.installer.config.system.build.isoImage
```
The resulting ISO will be in `result/iso/`.

## Testing with a VM
You can test the entire installation process using QEMU:
```bash
./modules/home/scripts/test-iso-vm
```

## Installation Guide (from ISO)
1. **Boot from the ISO:** Flash to USB and boot. (Initial user: `cwilliams`, password: `nixos`).
2. **Partition Disks:** Use `parted` or `fdisk` to create EFI (FAT32), Swap, and Root (ext4) partitions.
3. **Format and Mount:**
   ```bash
   sudo mkfs.fat -F 32 -n boot /dev/nvme0n1p1
   sudo mkfs.ext4 -L nixos /dev/nvme0n1p3
   sudo mount /dev/disk/by-label/nixos /mnt
   sudo mkdir -p /mnt/boot
   sudo mount /dev/disk/by-label/boot /mnt/boot
   ```
4. **Install:**
   ```bash
   sudo nixos-install --flake /etc/nix-config#cwilliams-laptop
   ```

# Directory Structure

- `hosts/<hostname>/`: Entry points for each machine.
- `modules/home/<domain>/`: Functional domains (dev, ops, desktop, etc.) for user configuration. See `modules/home/README.md` for details.
- `modules/home/home-shared.nix`: Universal Home Manager user settings.
- `modules/nixos/` & `modules/darwin/`: System-level modules.
- `modules/theming/`: Shared styling.
