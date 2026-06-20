# Installation Guide

This guide gets a new machine from a clean checkout to an activated system. The
macOS path is the fastest and most complete path because the bootstrap script can
install Nix, activate nix-darwin, and convert the checkout to Jujutsu.

## Fast Path: macOS

Run this from a macOS admin account. The bootstrap script verifies sudo access
before it tries to install Nix or activate nix-darwin.

### 1. Clone the repository

Fresh Macs normally have `git` before they have `jj`, so start with a normal Git
clone:

```bash
git clone https://github.com/cwilliams/.system-nix.git ~/.system-nix
```

If `git` is missing, install Apple's command line tools first:

```bash
xcode-select --install
```

### 2. Run the bootstrap script

```bash
~/.system-nix/scripts/bootstrap-macos
```

The script will:

- prompt for the Darwin hostname, defaulting to `cwilliams-work-laptop`;
- prompt before installing Nix if `nix` is not available;
- activate the selected nix-darwin configuration;
- convert the Git checkout into a colocated `jj` workspace when `jj` is
  available;
- print the macOS permissions that must be granted manually.

For noninteractive use:

```bash
~/.system-nix/scripts/bootstrap-macos --host cwilliams-work-laptop
```

Useful script options:

| Option             | Purpose                                                        |
| :----------------- | :------------------------------------------------------------- |
| `--host <name>`    | Use a hostname without prompting.                              |
| `--dry-run`        | Print the commands that would run without changing the system. |
| `--no-install-nix` | Fail instead of prompting to install Nix.                      |
| `--skip-jj`        | Leave the checkout as Git-only.                                |

### 3. If Nix was just installed

The Determinate installer may require a fresh shell before `nix` is on `PATH`.
If the script tells you to reopen the terminal, open a new shell and rerun:

```bash
~/.system-nix/scripts/bootstrap-macos
```

Manual Nix fallback: install Determinate Nix from the official macOS package, or
use the documented CLI installer:

```bash
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
```

References:

- [Determinate Nix quick start](https://docs.determinate.systems/)
- [Determinate Nix Installer](https://determinate.systems/nix-installer/)

### 4. Grant macOS permissions

After the initial activation, open **System Settings > Privacy & Security** and
grant:

1. **Accessibility**
   - `/Library/Application Support/Kanata/kanata`
   - `OmniWM`
   - `/Library/Application Support/Skhd/skhd`
2. **Input Monitoring**
   - `/Library/Application Support/Kanata/kanata`
   - `OmniWM`
   - `/Library/Application Support/Skhd/skhd`
3. **Full Disk Access** (optional but useful)
   - `OmniWM`

Approve the **pqrs.org Karabiner VirtualHIDDevice** system extension when macOS
prompts for it. This is required for Kanata's virtual keyboard support.

### 5. Verify the machine

```bash
jj st
darwin-rebuild --version
launchctl print system/org.nixos.kanata
```

After the first successful activation, future rebuilds use `sw`, which routes
to the correct `nh` switch command for the current platform and defaults to this
flake plus the current hostname:

```bash
sw
```

## macOS Troubleshooting

### `nix: command not found`

Open a new terminal and rerun the bootstrap script. If it still fails, install
Determinate Nix manually using the links above, then rerun the bootstrap script.

### Homebrew or tap activation fails

The Darwin config manages Homebrew through `nix-homebrew`. Confirm network and
work Git access are available, then rerun:

```bash
~/.system-nix/scripts/bootstrap-macos
```

### Karabiner VirtualHIDDevice was not approved

Check **System Settings > Privacy & Security** for a blocked system extension.
The related service log is:

```bash
tail -n 100 /var/log/karabiner-vhidmanager.log
```

### Kanata is not responding

Confirm Accessibility and Input Monitoring permissions for
`/Library/Application Support/Kanata/kanata`, then check:

```bash
launchctl print system/org.nixos.kanata
tail -n 100 /var/log/kanata.log
```

### skhd hotkeys are not responding

Confirm Accessibility and Input Monitoring permissions for
`/Library/Application Support/Skhd/skhd`. The LaunchAgent intentionally runs this
stable binary instead of a Nix store or profile symlink so macOS permissions
survive rebuilds.

Check the service and logs:

```bash
launchctl print gui/$(id -u)/org.nix-community.home.skhd
tail -n 100 ~/Library/Logs/skhd.err.log
tail -n 100 ~/Library/Logs/skhd.out.log
```

After changing permissions, restart the agent:

```bash
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/org.nix-community.home.skhd.plist 2>/dev/null || true
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/org.nix-community.home.skhd.plist
launchctl kickstart -k gui/$(id -u)/org.nix-community.home.skhd
```

## Other Platforms

### NixOS

Clone this repository to `$HOME/.system-nix`, then switch the host:

```bash
sudo nixos-rebuild switch --flake ~/.system-nix#<hostname>
```

### WSL2 / Standalone Home Manager

Ensure Nix is installed, then activate the standalone Home Manager profile:

```bash
nix-shell -p home-manager --run "home-manager switch --flake ~/.system-nix#cwilliams@<hostname>"
```

## Windows VM Installation

This repository can be booted and explored inside a Windows-hosted VM by using
the custom installer ISO. That path is useful for testing the live image,
verifying the graphical environment, and rehearsing the install flow.

The repository does **not** currently include a dedicated VM host like
`hosts/windows-vm/` or `hosts/qemu-vm/`. The documented laptop target
(`cwilliams-laptop`) is tied to bare-metal hardware and should not be treated
as a reusable VM profile.

### What this path supports today

- Booting the custom installer ISO in a Windows hypervisor.
- Exploring the live environment with the repo already available at
  `/etc/nix-config`.
- Manually partitioning a virtual disk and rehearsing `nixos-install`.

### What is still a gap

- There is no VM-specific NixOS host configuration in `hosts/`.
- `cwilliams-laptop` imports hardware-specific settings for the physical laptop
  such as disk UUIDs, GPU configuration, and kernel choices.
- A production VM install should wait for a dedicated VM host entry or a fresh
  hardware configuration generated from inside the guest.

### 1. Build the installer ISO on an existing Nix machine

Build from this repository on an existing NixOS, nix-darwin, or other machine
that already has Nix working:

```bash
cd ~/.system-nix
nix build .#nixosConfigurations.installer.config.system.build.isoImage --out-link result-iso
```

The ISO will be available under `result-iso/iso/`.

### 2. Move the ISO to Windows

Copy the generated `.iso` file to the Windows machine by whatever method is
convenient for you, for example:

- a shared folder;
- `scp`/SFTP;
- a USB drive;
- a cloud drive.

### 3. Create the VM on Windows

Use a Windows hypervisor that can boot an `x86_64` UEFI ISO. Hyper-V Generation
2 VMs and typical desktop hypervisors with EFI enabled both fit that
requirement.

Recommended baseline settings:

- `x86_64` guest
- 4 vCPUs
- 8 GB RAM minimum
- 40 GB virtual disk minimum
- EFI/UEFI boot enabled

If the hypervisor exposes a graphics adapter choice, prefer the default virtual
adapter first. The installer ISO already includes QEMU guest additions for local
testing, but Windows-hosted hypervisors may expose different virtual hardware.

### 4. Boot the live ISO

Boot the VM from the copied ISO.

The live environment is configured with:

- user: `cwilliams`
- password: `nixos`
- repository checkout available at `/etc/nix-config`

### 5. Partition and mount the virtual disk

The exact disk name depends on the hypervisor. Inside the live environment,
identify it first:

```bash
lsblk
```

Then create an EFI system partition and a root partition on the VM disk using
your preferred tooling (`cfdisk`, `parted`, or `gdisk`). After partitioning,
format and mount them, substituting the correct device names:

```bash
sudo mkfs.fat -F 32 -n boot /dev/<disk>p1
sudo mkfs.ext4 -L nixos /dev/<disk>p2
sudo mount /dev/disk/by-label/nixos /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/disk/by-label/boot /mnt/boot
```

If you also create swap, initialize it before installation.

### 6. Understand the current install limitation

At this point you can rehearse the installer workflow, but the repository does
not yet ship a safe VM target to install.

Do **not** assume this command is correct for a VM:

```bash
sudo nixos-install --flake /etc/nix-config#cwilliams-laptop
```

`cwilliams-laptop` depends on the laptop's generated hardware configuration and
desktop assumptions. Installing that host directly into a VM will require manual
rework at minimum and may fail outright.

### 7. If you want a real installed VM

The missing piece is a dedicated VM host configuration. Once that exists, the
expected flow will be:

1. Boot the installer ISO in the Windows VM.
2. Partition and mount the virtual disk.
3. Generate a VM hardware profile with `nixos-generate-config --root /mnt`.
4. Add a new host entry such as `hosts/windows-vm/`.
5. Run `sudo nixos-install --flake /etc/nix-config#<vm-hostname>`.

## Custom NixOS Installer ISO

Build the custom installer ISO:

```bash
nix build .#nixosConfigurations.installer.config.system.build.isoImage
```

The resulting ISO will be in `result/iso/`.

Test the installation process in QEMU:

```bash
./modules/home/scripts/test-iso-vm
```

From the live ISO:

1. Boot from the ISO. Initial user: `cwilliams`, password: `nixos`.
2. Partition disks with EFI, swap, and root partitions.
3. Format and mount:

   ```bash
   sudo mkfs.fat -F 32 -n boot /dev/nvme0n1p1
   sudo mkfs.ext4 -L nixos /dev/nvme0n1p3
   sudo mount /dev/disk/by-label/nixos /mnt
   sudo mkdir -p /mnt/boot
   sudo mount /dev/disk/by-label/boot /mnt/boot
   ```

4. Install:

   ```bash
   sudo nixos-install --flake /etc/nix-config#cwilliams-laptop
   ```
