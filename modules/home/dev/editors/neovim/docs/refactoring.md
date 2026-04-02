# 󰁨 Refactoring & Structural Edits

Focused on structural selection, symbol renaming, and AST-aware modifications.

## 󰘦 Refactor & Replace Group (<leader>r)

Consolidates all tools for changing code across symbols and files.

- `<leader>rn`: **Rename** symbol (LSP, Project-wide).
- `<leader>rr`: Standard **Search & Replace** (Grug-far).
- `<leader>ra`: **AST-Grep** Structural Search (Grug-far).
- `<leader>rf`: Search & Replace in current **File** (Grug-far).

## 󰘦 Structural Selection (Text Objects)

These use Tree-sitter to match exact code blocks. Use with `v` (visual) or an operator (`d`, `c`, `y`).

- `af` / `if`: **Function** (Outer/Inner)
- `ac` / `ic`: **Class** (Outer/Inner)
- `aa` / `ia`: **Argument/Parameter** (Outer/Inner)
- `al` / `il`: **Loop** (Outer/Inner)
- `ai` / `ii`: **Conditional/If** (Outer/Inner)

## 󰘦 Advanced Refactoring Tips

### 1. The "Delete/Change Function" Workflow

Instead of visual selection, use the direct operator:

- `daf`: **Delete** an entire function.
- `cia`: **Change** inside an argument (clears the arg and puts you in insert mode).
- `yac`: **Yank** an entire class.

### 2. Rapid Data Cleanup with Align (`&`)

Select a block of code or data and press `&`.

- **Example:** Select lines of variable assignments, press `&`, then type `=`. All `=` will align vertically, making the code significantly more readable.

### 3. Context-Aware Code Actions (`<leader>a`)

Many refactors are language-specific and handled by the LSP:

- **TypeScript:** Extract to constant, extract to function, convert to arrow function.
- **Rust:** Implement missing members, extract variable.
- Always check `<leader>a` when the cursor is on a symbol or selection!

### 4. Visual Selection Search (`*` / `#`)

Highlight any block of text and press `*` to find the next occurrence or `#` for previous. This works perfectly for non-symbol text that LSP rename might miss.

## 󱄅 See Also

- **[lsp.md](./lsp.md):** Core LSP features and code actions.
- **[grug-far.md](./grug-far.md):** Deep dive into advanced search and replace.
- **[navigation.md](./navigation.md):** Structural movement (Treewalker).
