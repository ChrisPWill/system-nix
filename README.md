# Useful zsh aliases (after first time)

* Run home-manager switch with `hms`
* Run nixos-rebuild switch with `nrs`
* Run darwin-rebuild switch with `drs`
* Switch into one of the `/devshells` with `nd <devshell name>` e.g. `nd node22`

# Installation

## Initial steps

Clone into `$HOME/.system-nix` using jujutsu (git works too)

If cloning to a different directory, update config.nixConfigDir in the home manager config for the host to ensure home manager config can find the out-of-store config files.

## NixOS

TODO

## MacOS (Darwin)

TODO

## WSL2

Easiest way to activate on home-manager:

```zsh
nix-shell -p home-manager --run "home-manager switch --extra-experimental-features nix-command --extra-experimental-features flakes --flake .#cwilliams@cwilliams-personal-wsl2"
```

After that, it should be possible to run the alias from anywhere

```zsh
hms
```

# Custom Installer ISO

You can build a custom NixOS installer ISO that comes pre-configured with your system settings and contains this configuration flake.

## Build the ISO

```bash
nix build .#nixosConfigurations.installer.config.system.build.isoImage
```

The resulting ISO will be in `result/iso/`.

## Installation Guide

### 1. Boot from the ISO
Flash the ISO to a USB drive and boot from it. The live environment will automatically have your user account `cwilliams` (initial password: `nixos`) and your graphical environment configured.

### 2. Partition Disks
You will need to partition your disks manually before running the installation. Below is a standard GPT/EFI partitioning scheme:

```bash
# Identify your disk (e.g., /dev/nvme0n1 or /dev/sda)
lsblk

# Create a new GPT partition table
sudo parted /dev/nvme0n1 -- mklabel gpt

# Create the EFI Boot partition (512MB)
sudo parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 513MiB
sudo parted /dev/nvme0n1 -- set 1 esp on

# Create the Swap partition (e.g., 8GB)
sudo parted /dev/nvme0n1 -- mkpart swap linux-swap 513MiB 8.5GiB

# Create the Root partition (Remaining space)
sudo parted /dev/nvme0n1 -- mkpart root ext4 8.5GiB 100%
```

### 3. Format and Mount
```bash
# Format partitions
sudo mkfs.fat -F 32 -n boot /dev/nvme0n1p1
sudo mkswap -L swap /dev/nvme0n1p2
sudo mkfs.ext4 -L nixos /dev/nvme0n1p3

# Mount partitions
sudo mount /dev/disk/by-label/nixos /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/disk/by-label/boot /mnt/boot
sudo swapon /dev/nvme0n1p2
```

### 4. Install NixOS
The installer ISO includes this flake at `/etc/nix-config`. You can use it to install your laptop's configuration:

```bash
sudo nixos-install --flake /etc/nix-config#cwilliams-laptop
```

Once finished, reboot into your new system:
```bash
sudo reboot
```
