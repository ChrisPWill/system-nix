# 󰙅 Structural & Plugin Navigation

This config focuses on high-speed, structural, and "jump-based" movement.

## 󰙅 Treewalker (Structural Movement)

Move through the code hierarchy without breaking syntax.

- `Alt-h` / `Alt-l`: Move **In/Out** of nodes (e.g., into a function body).
- `Alt-j` / `Alt-k`: Move **Down/Up** to the next sibling node.
- `Alt-Shift-h/j/k/l`: **Swap** the current node with a neighbor.

## 󰘦 Jumps & Marks

- ``: **Leap** (Enter 2 characters to jump anywhere on screen).
- `\s`: **Leap Treesitter** (Select TS nodes on screen).
- `;`: **Arrow Line** (Jump to a marked line in the current buffer).
- `<leader>;`: **Arrow File** (Jump to a marked file).
- `<leader>/;`: **Marks** (Standard Vim marks via Snacks picker).

## 󰘦 Structural Jump (Treesitter)

- `]f` / `[f`: Next/Prev **function** start.
- `]F` / `[F`: Next/Prev **function** end.
- `]c` / `[c`: Next/Prev **class** start.
- `]a` / `[a`: Next/Prev **argument** start.
- `]l` / `[l`: Next/Prev **loop** start.
- `]i` / `[i`: Next/Prev **conditional** start.

## 󰘦 Buffer & Search

- `gn` / `gp`: **Next/Prev** Buffer.
- `ga`: **Last** accessed file.
- `gm`: **Modified** recent files (Snacks picker).
- `<leader>f`: **Find Files** (Snacks picker).
- `<leader>//`: **Grep Search** (Snacks picker).

## 󱄅 See Also

- **[KEYMAPS.md](./KEYMAPS.md):** Core mapping philosophy and universal defaults.
- **[lsp.md](./lsp.md):** Specialized LSP-based navigation (Definitions, References, Symbols).
