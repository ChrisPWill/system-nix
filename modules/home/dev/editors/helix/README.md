# Helix Configuration

A Helix configuration aligned with the project's **Hybrid Philosophy** to provide a seamless transition between Helix and Neovim (`meow`).

## 󰘦 Alignment Strategy

- **LSP & Tooling Parity:** Helix is configured to use the same LSPs and formatters as the Neovim setup (e.g., `nixd`, `basedpyright`, `ruff`, `rust-analyzer`).
- **UI/UX Sync:** Visual settings (Relative lines, cursor shapes, theme) should be kept in sync with the Neovim UX to minimize context switching friction.
- **Auto-Formatting:** Enabled by default for all supported languages using the same tools as Neovim.

For Kotlin, Helix uses JetBrains' official alpha `kotlin-lsp` for diagnostics and formatting. The LSP's IntelliJ code-style engine applies the closest EditorConfig settings, including `ij_kotlin_*` properties and EditorConfig files outside source roots. No editor-side `ktlint` formatter or check is configured; repository Gradle lint tasks remain available separately.

## 󱄅 Nix Implementation

The configuration is managed in `modules/home/dev/editors/helix/default.nix`. It:

1. Configures `programs.helix.languages` to map executable names to languages.
2. Leaves language binaries out of `home.packages`; named devshells provide them.
3. Overrides styling targets where needed to retain the Hybrid UX.

Run `hx --health <language>` inside and outside a representative devshell to
inspect detection. Missing tools outside a shell are expected. Launch `hx` from
`nd <shell>` or from an envoluntary-mapped directory so it inherits the active
`PATH`.
