# 󰘦 Language Server (LSP) Features

This config leverages LSP for deep code understanding, navigation, and automated modifications.

## 󰙅 Navigation (Helix-aligned `g` prefix)

| Key     | Action                                  |
| :------ | :-------------------------------------- |
| `gd`    | **Goto Definition**                     |
| `gy`    | **Goto Type Definition**                |
| `gr`    | **Goto References** (Snacks picker)     |
| `gI`    | **Goto Implementation** (Snacks picker) |
| `gD`    | **Goto Declaration**                    |
| `K`     | **Hover Documentation**                 |
| `<C-k>` | **Signature Help**                      |

## 󰘦 Search & Picking

High-speed symbol discovery across your project.

- `<leader>s` / `<leader>/s`: **Document Symbols** (Current file).
- `<leader>S` / `<leader>/S`: **Workspace Symbols** (All files).
- `<leader>d`: **Document Diagnostics** (Current file).
- `<leader>D`: **Workspace Diagnostics** (All files).

## 󰘦 Refactor & Replace Group (<leader>r)

Consolidates all tools for changing code across symbols and files.

- `<leader>rn`: **Rename** symbol (LSP, Project-wide).
- `<leader>rr`: Standard **Search & Replace** (Grug-far).
- `<leader>ra`: **AST-Grep** Structural Search (Grug-far).
- `<leader>rf`: Search & Replace in current **File** (Grug-far).

## 󰘦 Code Actions & Tools

- `<leader>a`: **Code Action** (Fixes, imports, refactors).
- `<leader>cf`: **Format** selection or buffer (Conform).
- `<leader>Wa/r/l`: Manage **Workspace folders**.

## 󰙅 Diagnostics Navigation

- `]d` / `[d`: Next/Prev diagnostic.
- `<leader>td`: **Toggle** diagnostics in the buffer.

## 󰙅 Diagnostics & Symbols (Trouble)

- `<leader>tx`: **Trouble Diagnostics** (List-view).
- `<leader>ts`: **Trouble Symbols** (LSP list).
- `<leader>tl`: **Trouble LSP** (References/Definitions/etc).
- `<leader>tq / tL`: **Quickfix / Loclist** with Trouble.

## 󱄅 See Also

- **[navigation.md](./navigation.md):** Structural and plugin-based movement.
- **[KEYMAPS.md](./KEYMAPS.md):** Core mapping philosophy.
- **[rust.md](./rust.md) / [typescript.md](./typescript.md):** Language-specific extensions.
