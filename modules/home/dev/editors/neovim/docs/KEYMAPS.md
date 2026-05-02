# Neovim Keymapping Philosophy

This configuration follows a **Hybrid Philosophy** designed to reduce friction when switching between Neovim and Helix while preserving the strength of both.

## 1. Core "Verb-Noun" Integrity

Unlike Helix, which uses "Selection-Action," this configuration retains Neovim's native **Operator-Pending** model.

- `d` (delete), `c` (change), and `y` (yank) precede the motion or text object.
- Example: `diw` (delete inside word) remains standard.

## 2. Helix-Aligned Navigation (`g` Prefix)

"Goto" operations are aligned with Helix defaults for consistent spatial movement:

- `gh`: Line start
- `gl`: Line end
- `gs`: First non-blank character
- `ge`: Last line of file
- `gt`: Top of window
- `gb`: Bottom of window
- `gc`: Center of window
- `ga`: Last accessed file
- `gf`: File under cursor
- `gm`: Recent files
- `gd`: Definition
- `gy`: Type definition
- `gD`: Declaration
- `gr`: References
- `gI`: Implementation

## 3. Buffer & Match Management

- `gn`: Next buffer
- `gp`: Previous buffer
- `mm`: Match bracket
- `ms / md / mr`: Add / Delete / Replace **Surround**
- `mf / mh / mn`: Find / Highlight / Update **Surround**
- `]d / [d`: Next / Previous diagnostic

## 4. Selection, Alignment & Editing

To preserve standard Neovim behaviors like `&` (Repeat substitute) and `gn` (Search and Select), custom tools are mapped as follows:

- `&`: **Standard Neovim** (Repeat last substitution)
- `ma`: Align selections (Regex)
- `mA`: Align selections (Interactive)
- `M-n`: Search forward and select (Native `gn`)
- `M-N`: Search backward and select (Native `gN`)
- `Ctrl-Alt-j`: Move selection down (Restores `J` for joining lines)
- `Ctrl-Alt-k`: Move selection up (Restores `K` for keyword lookup)

## 5. Commenting

Because `gc` is aligned with Helix for "Center of window," commenting is mapped to `Ctrl-C`:

- `Ctrl-C`: Toggle comment (Line in Normal mode, Selection in Visual mode)

## 6. Buffer & Tab Management

- `gn`: Next buffer
- `gp`: Previous buffer
- `<leader>]t`: Next tab
- `<leader>[t`: Previous tab

## 7. Flat Leader Map ("Space" Mode)

High-frequency actions mapped to single keys under the `<leader>` (Space) prefix:

- `<leader>f`: Find files
- `<leader>gf`: Find git files
- `<leader>F`: Smart find files (Files, Recents, Buffers)
- `<leader>b`: Search open buffers
- `<leader>d`: Buffer diagnostics
- `<leader>D`: Workspace diagnostics
- `<leader>s`: Document symbols
- `<leader>S`: Workspace symbols
- `<leader>W`: Workspace management
- `<leader>a`: Code actions
- `<leader>r`: **Refactor / Replace group** (`rn`: Rename, `rr`, `rw`, `ra`, `rf`, `rs`, `rv`)
- `<leader>w`: Window management (mapped to `<C-w>`)

## 8. Domain-Specific Groups

Secondary tools are organized into mnemonic groups:

- `<leader>/`: **Search / Pick** (Grep, Help, Symbols, Find Class / Type: `i`, Undo, Knowledge Base, etc.)
- `<leader>g`: **Git Group** (LazyGit: `gg`, LazyJJ: `gj`, Tig Blame: `gb`, Inline Blame: `gl`, Stage: `gs`, Reset: `gr`, etc.)
- `<leader>c`: **Code Group** (Format: `cf`, Testing: `ct`, Breakpoints: `cb`)
- `<leader>A`: **AI Group** (Ask: `Aa`, Toggle: `At`)
- `<leader>t`: **Toggles** (Diagnostics: `td`, Formatting: `tf`, Markview: `tm`, Trouble: `tx`/`ts`/`tl`/`tq`/`tL`)
- `<leader>un`: Dismiss notifications
- `<leader>k`: **Knowledge & Snippets** (Cheat-sheet: `kc`, Keymaps: `km`, Snippets: `ks`/`ka`)

## 9. Plugin-Specific Navigation

- `]g / [g`: Next/Previous Git hunk
- `]f / [f`: Next/Previous Function start
- `]F / [F`: Next/Previous Function end
- `]c / [c`: Next/Previous Class start
- `]C / [C`: Next/Previous Class end
- `]a / [a`: Next/Previous Argument/Parameter
- `]A / [A`: Swap with Next/Previous Argument
- `]l / [l`: Next/Previous Loop
- `]i / [i`: Next/Previous Conditional (If)
- `} / {`: **Repeat** Next/Previous motion

## 10. Enhancement over Defaults

- `n / N`: Search results are always centered.
- `<C-d> / <C-u>`: Half-page scrolling is always centered.
- `j / k`: Smart word-wrap navigation (visual line movement).

## 11. Documentation

See **[cheatsheet.md](./cheatsheet.md)** for a quick reference, and **[clobbered-keybinds.md](./clobbered-keybinds.md)** for a full list of overridden standard Neovim mappings.
