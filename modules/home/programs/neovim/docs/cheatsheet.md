#  Neovim Custom Features Cheat-sheet

This configuration uses a **Hybrid Philosophy** (Helix-inspired navigation + Neovim power).

## 󰌌 Essential Custom Mappings

| Key | Action | Plugin |
| :--- | :--- | :--- |
| `-` | **Explorer** (File Tree) | Snacks.explorer |
| `Ctrl-\` | **Terminal** (Floating) | Snacks.terminal |
| `gn / gp` | **Next / Prev Buffer** | Core |
| `<leader>_` | **LazyGit** | Snacks.lazygit |
| `<leader>j` | **LazyJJ** | Snacks.terminal |
| `\` | **Leap** (Jump to characters) | leap.nvim |
| `;` | **Arrow** (Jump to marked line) | arrow.nvim |
| `<leader>;` | **Arrow** (Jump to marked file) | arrow.nvim |
| `ms/md/mr` | **Surround** (Add/Delete/Replace) | mini.surround |
| `mf/mh/mn` | **Surround** (Find/Highlight/Update) | mini.surround |
| `&` | **Align** (Regex alignment) | mini.align |
| `g&` | **Align** (Interactive preview) | mini.align |

## 󰘦 Toggles & UI (<leader>t / <leader>u)

| Key | Action | Plugin |
| :--- | :--- | :--- |
| `<leader>td` | **In-buffer Diagnostics** | LSP |
| `<leader>tf` | **Autoformat** | Conform |
| `<leader>tm` | **Markview** | Markview |
| `<leader>tx` | **Trouble Diagnostics** | Trouble |
| `<leader>ts` | **Trouble Symbols** | Trouble |
| `<leader>tl` | **Trouble LSP** | Trouble |
| `<leader>tq / tL` | **Quickfix / Loclist** | Trouble |
| `<leader>un` | **Dismiss Notifications** | Noice |

## 󰘦 Global Search & Pickers

High-frequency actions mapped to single keys under the Space leader:
- `<leader>f`: **Find Files** (Snacks Picker)
- `<leader>gf`: **Find Git Files**
- `<leader>sf`: **Smart Find Files** (Combined Files/Recent/Buffers)
- `<leader>b`: **Search Buffers**
- `<leader>d`: **Buffer Diagnostics**
- `<leader>D`: **Workspace Diagnostics**
- `<leader>s`: **Document Symbols**
- `<leader>S`: **Workspace Symbols**
- `<leader>a`: **Code Actions**

## 󰘦 Refactor & Replace (<leader>r)

Consolidated group for changing code:
- `<leader>rn`: **Rename** Symbol (LSP, Project-wide).
- `<leader>rr`: Standard Project Search/Replace (Grug-far).
- `<leader>rw`: Search/Replace **Word** under cursor.
- `<leader>ra`: **AST-Grep** Structural Search (Grug-far).
- `<leader>rf`: Search/Replace in current **File** (Grug-far).
- `<leader>rs`: Search/Replace from **Search Register** (/).
- `<leader>rv`: Search/Replace from **Visual Selection**.

## 󰘦 Search / Pick Group (<leader>/)

| Key | Action |
| :--- | :--- |
| `<leader>/k` | **Knowledge Base** (Files) |
| `<leader>/K` | **Knowledge Base** (Grep contents) |
| `<leader>/;` | **Marks** (Aligns with arrow.nvim) |
| `<leader>/m` | **Keymaps** Search |
| `<leader>/h` | **Help Pages** |
| `<leader>/l` | **Location List** |
| `<leader>/M` | **Man Pages** |
| `<leader>/q` | **Quickfix List** |
| `<leader>/R` | **Resume** (Last Picker) |
| `<leader>/u` | **Undo History** |
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
