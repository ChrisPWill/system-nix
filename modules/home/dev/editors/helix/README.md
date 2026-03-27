# Helix Configuration

A Helix configuration aligned with the project's **Hybrid Philosophy** to provide a seamless transition between Helix and Neovim (`meow`).

## 󰘦 Alignment Strategy

- **LSP & Tooling Parity:** Helix is configured to use the same LSPs and formatters as the Neovim setup (e.g., `nixd`, `basedpyright`, `ruff`, `rust-analyzer`).
- **UI/UX Sync:** Visual settings (Relative lines, cursor shapes, theme) should be kept in sync with the Neovim UX to minimize context switching friction.
- **Auto-Formatting:** Enabled by default for all supported languages using the same tools as Neovim.

## 󱄅 Nix Implementation

The configuration is managed in `modules/home/dev/editors/helix/default.nix`. It explicitly:
1.  Declares all necessary LSP and formatter binaries in `home.packages`.
2.  Configures `programs.helix.languages` to map these binaries to their respective languages.
3.  Overrides default styling targets (like Stylix) where necessary to ensure precise manual alignment with the "Hybrid" UX.
