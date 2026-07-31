# NixOS Module Architecture

Blueprint exports the files and directory entry points in this directory as
`nixosModules.<name>`. Hosts compose those modules in `hosts/<hostname>/`.

## Shared Layers

- **`nix-core.nix`**: Flakes, binary caches, garbage collection, and store optimisation.
- **`host-shared.nix`**: The small base shared with nix-darwin hosts; currently imports `nix-core` and enables the common shells and `btop`.
- **`nixos-shared.nix`**: Settings for every NixOS system, including users, locale, Docker, SSH, Flatpak, Stylix, and the `ops/` module.

## Optional Roles and Capabilities

- **`graphical-environment/`**: Niri, DankMaterialShell greeter, Kanata, PipeWire, portals, printing, and desktop packages.
- **`personal-machine.nix`**: Steam, gaming/VPN packages, and personal-machine firewall rules.
- **`cachyos.nix`**: CachyOS kernel overlay, caches, and the `ntsync` kernel module.
- **`gamemode.nix`**: GameMode plus the NVIDIA offload helper.
- **`audio.nix`**: PipeWire audio; imported by `graphical-environment/`.
- **`ops/`**: System-level sops-nix configuration.

The primary laptop composes the shared, graphical, personal, CachyOS, and
GameMode layers. The installer composes the shared, graphical, and personal
layers without importing the laptop's hardware configuration.
