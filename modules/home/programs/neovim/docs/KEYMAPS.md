# Neovim Keymapping Philosophy

This configuration follows a **Hybrid Philosophy** designed to reduce friction when switching between Neovim and Helix while preserving the unique strengths of both editors.

## 1. Core "Verb-Noun" Integrity
Unlike Helix, which uses "Selection-Action," this configuration retains Neovim's native **Operator-Pending** model. 
- `d` (delete), `c` (change), and `y` (yank) still precede the motion or text object.
- Example: `diw` (delete inside word) remains standard.

## 2. Helix-Aligned Navigation (`g` Prefix)
"Goto" operations are aligned with Helix defaults to ensure consistent spatial movement across editors:
- `gh`: Line start (`0`)
- `gl`: Line end (`$`)
- `gs`: First non-blank character (`^`)
- `ge`: Last line of file (`G`)
- `gt`: Top of window (`H`)
- `gb`: Bottom of window (`L`)
- `gc`: Center of window (`M`)
- `ga`: Last accessed file (`<C-^>`)
- `gf`: File under cursor (`gf`)
- `gm`: Recent files (Snacks Picker)
- `gd`: Go to definition
- `gy`: Go to type definition
- `gD`: Go to declaration
- `gr`: Go to references
- `gI`: Go to implementation

## 3. Buffer & Match Management
Buffer navigation and matching logic are shifted to Helix-style mnemonics under the `m` (Match) prefix:
- `gn`: Next buffer
- `gp`: Previous buffer
- `mm`: Match bracket (replaces `%`)
- `ms` / `md` / `mr`: Match **Surround** (Add/Delete/Replace) — *`ms` in Visual mode surrounds selection; in Normal mode it expects a motion.*
- `mf` / `mh` / `mn`: Match **Surround** (Find/Highlight/Update n lines)
- `]d` / `[d`: Next/Previous diagnostic (Helix default)

## 4. Selection & Alignment
Additional tools that prioritize visual selection (Helix: Selection-Action):
- `&`: Align selections (via `mini.align`)
- `g&`: Align selections with interactive preview

## 5. Flat Leader Map ("Space" Mode)
High-frequency actions (Pickers and LSP) are mapped to single keys under the `<leader>` (Space) prefix, mirroring Helix's efficient "Space" mode:
- `<leader>f`: Find files (Snacks Picker)
- `<leader>gf`: Find git files (Snacks Picker)
- `<leader>sf`: Smart find files (Files, Recents, Buffers)
- `<leader>b`: Search open buffers
- `<leader>d`: Document diagnostics (current buffer)
- `<leader>D`: Workspace diagnostics (all buffers)
- `<leader>s`: Document symbols (LSP)
- `<leader>S`: Workspace symbols (LSP)
- `<leader>W`: Workspace management (Add/Remove/List folders)
- `<leader>a`: Code actions
- `<leader>r`: **Refactor / Replace group** (Rename: `rn`, Grug-far: `rr`, `rw`, `ra`, `rf`, `rs`, `rv`)
- `<leader>w`: Window management (mapped to `<C-w>`)
- `<leader>_`: LazyGit (Floating)
- `<leader>j`: LazyJJ (Terminal)

## 6. Domain-Specific Groups
To avoid clashes with the flat leader map, secondary tools are organized into mnemonic groups:
- `<leader>/`: **Search / Pick Group** (Grep, Help, Symbols, Undo, Knowledge Base: `k`, etc.)
- `<leader>g`: **Git Group** (Stage: `s`, Reset: `r`, Blame: `b`/`tb`, Diff: `d`/`D`, Deleted: `td`)
- `<leader>c`: **Code Group** (Format: `cf`, Fix: `cxa`, Testing: `ct`, Breakpoints: `cb`)
- `<leader>A`: **AI Group** (Avante Ask: `Aa`, Toggle: `At`)
- `<leader>t`: **Toggles** (Diagnostics: `td`, Formatting: `tf`, Markview: `tm`, Trouble: `tx`/`ts`/`tl`/`tq`/`tL`)
- `<leader>un`: Dismiss notifications (Noice)
- `<leader>k`: **Knowledge & Snippets** (Cheat-sheet: `kc`, Keymaps: `km`, Snippets: `ks`/`ka`)

## 7. Plugin-Specific Navigation
Navigation within plugins is aligned where possible:
- `]g` / `[g`: Next/Previous Git hunk (replaces `]c`/`[c`)
- `]f` / `[f`: Next/Previous Function start
- `]F` / `[F`: Next/Previous Function end
- `]c` / `[c`: Next/Previous Class start
- `]C` / `[C`: Next/Previous Class end
- `]a` / `[a`: Next/Previous Argument/Parameter
- `]A` / `[A`: **Swap** with Next/Previous Argument
- `]l` / `[l`: Next/Previous Loop
- `]i` / `[i`: Next/Previous Conditional (If)
- `}` / `{`: **Repeat** Next/Previous motion (Works for TS moves and `f`/`F`/`t`/`T`)

## 8. Enhancement over Defaults
Where Neovim defaults are "lazy," this config adds centering and improved behavior:
- `n`/`N`: Next/Previous search results are always centered (`zz`).
- `<C-d>`/`<C-u>`: Half-page scrolling is always centered.
- `j`/`k`: Smart word-wrap navigation (moves by visual line if no count is provided).

## 9. Documentation
For a quick reference of all custom mappings and specialized plugin workflows, see **[cheatsheet.md](./cheatsheet.md)**.
