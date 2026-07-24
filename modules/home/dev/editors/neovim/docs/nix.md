# 󱄅 Nix-Native Development

This configuration is built for a NixOS/Darwin system, leveraging the `nixCats` framework.

## 󰙅 Structure

- **`default.nix`**: Derivation and plugin management.
- **`config/`**: Standard Neovim configuration files.
- **`docs/`**: Personal Knowledge Base and Cheat-sheet.

## 󰌌 Keybindings

- `nvimconfig`: Zsh alias to jump to the Neovim config.

## 󰘦 Nix-Aware Tools

Enter `nd nix` for a standalone Nix project. This repository maps to the
composite `system-nix` shell through envoluntary.

- **LSP:** `nixd` provides diagnostics and completion.
- **Linting:** `statix` and `deadnix` provide buffer diagnostics through `nvim-lint`.
- **Formatting:** `alejandra` is the default formatter via `conform.nvim`.
- **Tree-sitter:** Parsers for `nix` and `just` are pre-installed.

## 󰘦 Practical Tips

- **Adding Plugins:** Add to `optionalPlugins.general` in `default.nix` and use `packadd` in `config/`.
- **Reference Guides:** Maintain reference guides in `docs/` for any new complex plugins.
- **Symlinking:** The `config/` and `docs/` directories are symlinked as out-of-store to allow for rapid iteration.
