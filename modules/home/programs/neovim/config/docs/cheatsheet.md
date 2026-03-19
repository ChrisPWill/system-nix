#  Neovim Custom Features Cheat-sheet

This configuration uses a **Hybrid Philosophy** (Helix-inspired navigation + Neovim power).

## 󰌌 Essential Custom Mappings

| Key | Action | Plugin |
| :--- | :--- | :--- |
| `-` | **Explorer** (File Tree) | Snacks.explorer |
| `Ctrl-` | **Terminal** (Floating) | Snacks.terminal |
| `` | **Leap** (Jump to characters) | leap.nvim |
| `;` | **Arrow** (Jump to marked line) | arrow.nvim |
| `<leader>;` | **Arrow** (Jump to marked file) | arrow.nvim |
| `ms/md/mr` | **Surround** (Add/Delete/Replace) | mini.surround |
| `&` | **Align** (Regex alignment) | mini.align |

## 󰘦 Search & Replace (Grug-far)

Access via the `<leader>r` group:
- `<leader>rr`: Standard Project Search/Replace.
- `<leader>ra`: **AST-Grep** (Structural Search).
- `<leader>rf`: Search/Replace in current **File**.

## 󰘦 Knowledge & Snippets

Access via the `<leader>k` group:
- `<leader>kk`: Browse **Personal Knowledge Base** (`docs/`).
- `<leader>kc`: Open this **Cheat-sheet**.
- `<leader>ks`: Search / Edit **Snippets**.
- `<leader>ka`: Add new **Snippet** (supports visual selection).

## 󰘦 Code & LSP

| Key | Action | Mode |
| :--- | :--- | :--- |
| `<leader>a` | **Code Action** | Normal |
| `<leader>cf` | **Format** Buffer | Normal / Visual |
| `<leader>ctt` | **Test** Single (Neotest) | Normal |
| `gr` | **References** (Picker) | Normal |
| `K` | **Hover** Documentation | Normal |

## 󱄅 Where to find more info?

- **Keybindings Philosophy:** See `KEYMAPS.md` in the Neovim module root.
- **Architectural Overview:** See `README.md` in the Neovim module root.
- **Plugin Details:** Check `config/lua/plugins/` for individual plugin specs.
- **Personal Docs:** More detailed guides are in `config/docs/`.
