#  Grug-far Reference

A high-performance, structural search and replace tool for Neovim.

## 󰘦 Core Use-Cases

### 1. Project-wide Refactoring

When you need to rename a function, variable, or class across the entire codebase. Grug-far provides a live-preview buffer where you can see all matches and the resulting changes before applying them.

### 2. Structural Search (AST-Grep)

Use `<leader>ra` to search based on code structure rather than text.

- **Pattern:** `func($A, $B)` matches any function call with exactly two arguments.
- **Why:** Regex is brittle for code; AST-grep understands your programming language's grammar.

### 3. File-Scoped Search & Replace

Use `<leader>rf` to quickly clean up or refactor within the current buffer. This is faster than standard `:s/` for complex operations.

### 4. Search from Visual Selection

Highlight a block of code and use `<leader>rv` to find other occurrences or refactor that specific pattern.

## 󰌌 Keybindings

| Key          | Action                                        | Mode   |
| :----------- | :-------------------------------------------- | :----- |
| `<leader>rr` | **R**eplace (Standard Search)                 | Normal |
| `<leader>rw` | **R**eplace **W**ord under cursor             | Normal |
| `<leader>rf` | **R**eplace in current **F**ile               | Normal |
| `<leader>ra` | **R**eplace **A**st-grep (Structural)         | Normal |
| `<leader>rs` | **R**eplace from **/** Register (last search) | Normal |
| `<leader>rv` | **R**eplace **V**isual Selection              | Visual |

## 󱞩 Buffer-local (Inside Grug-far)

- `<leader>c`: **Close** Grug-far.
- `<C-enter>`: **Open location and close** Grug-far immediately.
- `\w` (localleader + w): **Toggle `--fixed-strings`** (Literal vs Regex).

## 󱘎 Advanced Features

- **Transient Mode:** Buffers are unlisted and deleted when closed to prevent clutter.
- **Live Preview:** Changes are reflected in the buffer as you type the replacement.
