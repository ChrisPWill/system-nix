#  Neovim Custom Features Cheat-sheet

This configuration uses a **Hybrid Philosophy** (Helix-inspired navigation + Neovim power).

## 󰌌 Essential Custom Mappings

| Key | Action | Plugin |
| :--- | :--- | :--- |
| `-` | **Explorer** (File Tree) | Snacks.explorer |
| `Ctrl-\` | **Terminal** (Floating) | Snacks.terminal |
| `\` | **Leap** (Jump to characters) | leap.nvim |
| `;` | **Arrow** (Jump to marked line) | arrow.nvim |
| `<leader>;` | **Arrow** (Jump to marked file) | arrow.nvim |
| `ms/md/mr` | **Surround** (Add/Delete/Replace) | mini.surround |
| `&` | **Align** (Regex alignment) | mini.align |

## 󰘦 Refactor & Replace (<leader>r)

Consolidated group for changing code:
- `<leader>rn`: **Rename** Symbol (LSP, Project-wide).
- `<leader>rr`: Standard Project Search/Replace (Grug-far).
- `<leader>ra`: **AST-Grep** Structural Search (Grug-far).
- `<leader>rf`: Search/Replace in current **File** (Grug-far).

## 󰘦 Search / Pick Group (<leader>/)

| Key | Action |
| :--- | :--- |
| `<leader>/k` | **Knowledge Base** (Files) |
| `<leader>/K` | **Knowledge Base** (Grep contents) |
| `<leader>/;` | **Marks** (Aligns with arrow.nvim) |
| `<leader>/m` | **Keymaps** Search |
| `<leader>/f` | **Find Files** |
| `<leader>//` | **Grep** (Search All) |

## 󰘦 Knowledge & Snippets Group (<leader>k)

| Key | Action |
| :--- | :--- |
| `<leader>kc` | Open this **Cheat-sheet** (Floating Window) |
| `<leader>km` | Open **Keymaps Guide** (Floating Window) |
| `<leader>kr` | Open **Neovim Quickref** (Floating Window) |
| `<leader>ks` | Search / Edit **Snippets** |
| `<leader>ka` | Add new **Snippet** (Visual selection supported) |

## 󱄅 Detailed Guides

Find more info in these dedicated reference guides (Browse with `<leader>/k`):
- **[KEYMAPS.md](./KEYMAPS.md):** Core mapping philosophy.
- **[lsp.md](./lsp.md):** LSP navigation, definitions, and code actions.
- **[refactoring.md](./refactoring.md):** Structural edits and AST search.
- **[navigation.md](./navigation.md):** Treewalker and plugin movement.
- **[vcs.md](./vcs.md):** Git workflow and Koji commits.
- **[snippets.md](./snippets.md):** Managing and using Snippets.
- **[testing.md](./testing.md):** Integrated testing runner.
- **[rust.md](./rust.md) / [typescript.md](./typescript.md) / [nix.md](./nix.md):** Language-specific tools.
- **[README.md](../README.md):** Architectural overview.
