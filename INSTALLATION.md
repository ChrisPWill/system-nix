# Installation Guide

This guide covers cloning the repository and setting up your environment across various platforms.

## Clone the Repository

Clone this repository to `$HOME/.system-nix`:

```bash
jj git clone https://github.com/cwilliams/.system-nix.git ~/.system-nix
# Or using standard git
git clone https://github.com/cwilliams/.system-nix.git ~/.system-nix
```

## Quick Start by Platform

### NixOS

For a new installation or bootstrapping from an existing NixOS system:

```bash
sudo nixos-rebuild switch --flake .#<hostname>
```

### macOS (Darwin)

Ensure Nix is installed (recommended: [Determinate Systems Nix Installer](https://github.com/DeterminateSystems/nix-installer)), then run:

```bash
nix run nix-darwin -- switch --flake .#cwilliams-work-laptop
```

### WSL2 / Standalone Home Manager

Ensure Nix is installed, then activate on a fresh system:

```bash
nix-shell -p home-manager --run "home-manager switch --flake .#cwilliams@<hostname>"
```

---

## Custom Installer ISO

You can build a custom NixOS installer ISO that comes pre-configured with your system settings.

### Build the ISO

```bash
nix build .#nixosConfigurations.installer.config.system.build.isoImage
```

The resulting ISO will be in `result/iso/`.

### Testing with a VM

You can test the entire installation process using QEMU:

```bash
./modules/home/scripts/test-iso-vm
```

### Installation Guide (from ISO)

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
