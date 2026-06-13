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

After the first successful activation, future rebuilds use `nhs`, which routes
to the correct `nh` switch command for the current platform:

```bash
nhs
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
