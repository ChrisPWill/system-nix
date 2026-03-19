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
- `gd`: Go to definition
- `gy`: Go to type definition
- `gr`: Go to references
- `gI`: Go to implementation

## 3. Buffer & Match Management
Buffer navigation and matching logic are shifted to Helix-style mnemonics:
- `gn`: Next buffer
- `gp`: Previous buffer
- `mm`: Match bracket (replaces `%`)
- `]d` / `[d`: Next/Previous diagnostic (Helix default)

## 4. Flat Leader Map ("Space" Mode)
High-frequency actions (Pickers and LSP) are mapped to single keys under the `<leader>` (Space) prefix, mirroring Helix's efficient "Space" mode:
- `<leader>f`: Find files (Snacks Picker)
- `<leader>b`: Search open buffers
- `<leader>d`: Document diagnostics (current buffer)
- `<leader>D`: Workspace diagnostics (all buffers)
- `<leader>s`: Document symbols (LSP)
- `<leader>S`: Workspace symbols (LSP)
- `<leader>W`: Workspace management (Add/Remove/List folders)
- `<leader>a`: Code actions
- `<leader>r`: Rename symbol
- `<leader>w`: Window management (mapped to `<C-w>`)

## 5. Domain-Specific Groups
To avoid clashes with the flat leader map, secondary tools are organized into mnemonic groups:
- `<leader>/`: **Search / Pick Group** (Grep, Help, Symbols, Undo, etc.)
- `<leader>g`: **Git Group** (Stage, Reset, Blame, Diff)
- `<leader>c`: **Code Group** (Format: `cf`, Fix: `cxa`, Testing: `ct`, Breakpoints: `cb`)
- `<leader>A`: **AI Group** (Avante Ask: `Aa`, Toggle: `At`)
- `<leader>t`: **Toggles** (Diagnostics: `td`, Formatting: `tf`)
- `<leader>x`: **Snippets** (Scissors Edit/Add)

## 6. Plugin-Specific Navigation
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

## 7. Enhancement over Defaults
Where Neovim defaults are "lazy," this config adds centering and improved behavior:
- `n`/`N`: Next/Previous search results are always centered (`zz`).
- `<C-d>`/`<C-u>`: Half-page scrolling is always centered.
- `j`/`k`: Smart word-wrap navigation (moves by visual line if no count is provided).
