# 󱘗 Rust Power Tools

Built using `rustaceanvim` for deep `rust-analyzer` and `cargo` integration.

## 󰘦 Essential Keybindings

| Key           | Action                                 | Mode   |
| :------------ | :------------------------------------- | :----- |
| `<leader>ce`  | **Explain Error** (RustLsp)            | Normal |
| `<leader>ctt` | **Testables** (Select a test to run)   | Normal |
| `<leader>ctp` | **Testables Previous** (Re-run)        | Normal |
| `<leader>crr` | **Runnables** (Select a binary to run) | Normal |
| `<leader>crp` | **Runnables Previous** (Re-run)        | Normal |
| `<leader>K`   | Open **docs.rs** documentation         | Normal |
| `K`           | **Hover** Documentation (Rust-aware)   | Normal |

## 󰙨 Debugging

Rust debugging is pre-configured via `nvim-dap`. Use `RustLsp debuggables` to start a session with the correct target.

## 󱄅 Configuration

- **Diagnostics:** Clippy is integrated via `nvim-lint`.
- **Formatting:** Handled by `rustfmt` via `conform.nvim`.
- **LSP:** Managed through `rustaceanvim` (separate from `nvim-lspconfig`).
