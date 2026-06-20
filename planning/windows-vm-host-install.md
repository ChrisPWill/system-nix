# Plan: Windows VM Host Install

**Priority:** 7

**Objective:** Add a supported NixOS VM host target for Windows-hosted
hypervisors so the installer ISO can be used for a real installation, not just
live-environment testing.

## Rationale

The repository already includes a custom installer ISO and local QEMU test
script, but the installation target documented today is `cwilliams-laptop`.
That host imports a generated `hardware-configuration.nix` tied to the physical
laptop:

- disk UUIDs for `/`, `/boot`, and swap;
- Intel/NVIDIA hardware settings;
- CachyOS kernel preferences intended for bare metal.

That makes the current ISO useful for VM boot testing on Windows, but not for a
repeatable VM installation path.

## Current Gaps

- No `hosts/<vm-name>/` entry exists for a virtual machine.
- No VM-specific `hardware-configuration.nix` is tracked.
- No documented guidance exists for whether Hyper-V, VirtualBox, or another
  Windows hypervisor should be the reference platform.
- The current installer instructions could be misread as if
  `nixos-install --flake /etc/nix-config#cwilliams-laptop` were appropriate for
  a VM.

## Proposed Direction

Create a dedicated host, for example `hosts/windows-vm/`, with:

- a VM-generated `hardware-configuration.nix`;
- `host-shared` and `nixos-shared` imports;
- only the graphical or personal-machine modules that actually make sense in a
  virtualized environment;
- kernel, GPU, and bootloader settings appropriate to the chosen Windows
  hypervisor.

If cross-hypervisor support is unrealistic, pick one documented reference path
and optimize for that first.

## Implementation Steps

1. Build and boot the existing installer ISO inside the chosen Windows
   hypervisor.
2. Generate a clean VM hardware config with `nixos-generate-config`.
3. Create `hosts/windows-vm/configuration.nix` and import only the modules that
   are valid in a VM.
4. Decide whether `personal-machine` should be reused as-is or split so VM
   hosts can avoid gaming, GPU, or other bare-metal assumptions.
5. Test `nixos-install` against the new host and verify the first boot.
6. Update `INSTALLATION.md` once the VM target is actually supported.

## Success Criteria

- A Windows-hosted VM can boot the repo's installer ISO and complete
  `nixos-install` against a dedicated flake host.
- The installed VM boots without manual removal of laptop-specific hardware
  settings.
- The installation guide can document a real VM target instead of a testing-only
  workflow.
