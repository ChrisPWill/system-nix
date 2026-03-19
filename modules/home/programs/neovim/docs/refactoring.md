# 󰁨 Refactoring & Structural Edits

Focused on structural selection and AST-aware modifications.

## 󰘦 Structural Selection (Text Objects)
These use Tree-sitter to match exact code blocks. Use with `v` (visual) or an operator (`d`, `c`, `y`).
- `af` / `if`: **Function** (Outer/Inner)
- `ac` / `ic`: **Class** (Outer/Inner)
- `aa` / `ia`: **Argument/Parameter** (Outer/Inner)
- `al` / `il`: **Loop** (Outer/Inner)
- `ai` / `ii`: **Conditional/If** (Outer/Inner)

## 󰘦 Multi-file Search & Replace
Use the `<leader>r` group for **Grug-far**:
- `<leader>rr`: Standard Project Replace.
- `<leader>ra`: **AST-Grep** (Search using structural patterns, e.g., `func($A, $B)`).

## 󰘦 Visual Mode Power
- `*` / `#`: Search forward/backward for the **currently selected text**.
- `<leader>rv`: Launch Grug-far with the **visual selection** as the search query.
- `ms` / `md` / `mr`: **Surround** add, delete, or replace.
- `&`: **Align** text based on a regex pattern (e.g., align on `=` or `,`).
