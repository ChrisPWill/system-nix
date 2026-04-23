# 󱘗 Kotlin Support

Robust support for Kotlin development using industry-standard tools.

## 󰘦 Features

- **LSP:** Powered by `kotlin-language-server` via `nvim-lspconfig`.
- **Formatting:** Handled by `ktlint` via `conform.nvim`.
- **Linting:** Integrated via `nvim-lint` using `ktlint`.
- **Tree-sitter:** Syntax highlighting and structural navigation are always enabled.

## 󰘦 Keybindings

Standard LSP keybindings apply for Kotlin:

| Key          | Action                  | Mode   |
| :----------- | :---------------------- | :----- |
| `<leader>cf` | **Format** code         | Normal |
| `K`          | **Hover** Documentation | Normal |
| `gd`         | **Go to Definition**    | Normal |
| `gr`         | **Go to References**    | Normal |
| `<leader>ca` | **Code Actions**        | Normal |
| `<leader>rn` | **Rename** Symbol       | Normal |

## 󱄅 Configuration

The Kotlin environment is gated by the `kotlin` category in `nixCats`.
To use it, ensure `kotlin = true` is set in your package definitions.
