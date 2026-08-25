# 󰙅 Custom Treesitter Tooling

Beyond the structural navigation covered in [navigation.md](./navigation.md),
a handful of custom features built directly on the treesitter parse tree
live under `lua/utils/treesitter/` and are wired up in
`lua/plugins/treesitter.lua`.

## 󰘦 Less-common Code Tools (`<leader>C`)

- `<leader>Cr`: Highlight every **return position** in the function
  enclosing the cursor — explicit `return` statements, or (for languages
  like Rust/Ruby with no `return` keyword for the common case) the implicit
  tail-expression return. Clears automatically once the cursor leaves the
  function.
- `<leader>Cm`: Highlight every **mutation site** (assignment,
  augmented-assignment, increment/decrement) of the identifier under the
  cursor, within its enclosing function (or the whole buffer for a
  module-level variable). Deliberately includes mutations inside nested
  closures — a lambda capturing and reassigning an outer variable is a
  genuine mutation site, not something to hide.
- `]R` / `[R`: Jump to the next/previous return position (see `<leader>Cr`
  above), following the same repeat-bracket conventions as the other
  structural motions in [navigation.md](./navigation.md).

## 󰘦 Structural Fold Summaries

Closed folds show a one-line structural summary instead of Neovim's default
`"N lines folded"`:

- A folded **function** shows its signature line, e.g.
  `fun classify(n: Int): String { (9 lines)`.
- A folded **`if`/`else if`/`else` chain** shows the whole branch structure
  on one line, e.g. `if (n > 10) { } else if (n > 0) { } else { (7 lines)`.
- A folded **`match`/`when`/`switch`** shows its subject plus each arm's own
  header, e.g. `match n { 0 => "zero", n if n > 0 => "positive", _ => "negative", (5 lines)`.
- Everything else (loops, classes, plain blocks) falls back to its own
  header/signature line.
- A trailing `(N lines)` is always appended.

This is generic across whatever treesitter grammar is active — it pattern-matches
on node type names rather than a per-language node list — so it should work
for any language with a parser installed, not just the ones called out above.

## Reusable building blocks

The above features share several small modules, kept generic on purpose so
a future feature can reuse them without re-deriving the same logic:

- `utils/treesitter/scope.lua`: find the function-like node enclosing a
  given node.
- `utils/treesitter/identifier.lua`: resolve "the identifier this node is
  really about" (e.g. the `count` in a `self.count` member access).
- `utils/treesitter/motion.lua`: move the cursor to the nearest of a list of
  nodes, relative to the cursor.
- `utils/treesitter/highlight.lua`: highlight a list of node ranges, with
  the highlight auto-clearing once the cursor leaves a given node's line
  range.
