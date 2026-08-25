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
- `<leader>Co`: Open an **outline** of every function/class-like
  declaration in the buffer (nested entries indented under their
  enclosing class/function) via a Snacks picker, and jump to the selected
  one. Built entirely from the treesitter parse tree, so it works even in
  a buffer with no LSP attached.
- `<leader>Ca`: Jump to where a new **argument/parameter** goes — the
  call/signature enclosing the cursor, or (from anywhere inside its body)
  the signature of the nearest enclosing function or class, including a
  Kotlin-style primary constructor — and start typing. Inserts whatever
  separator is needed first — a comma and space after the last existing
  argument, or just a space if there's already a trailing comma (e.g.
  rustfmt's multi-line style) — so you never hand-manage commas or hunt
  for the closing paren.

## 󰘦 Ambient Reference Highlighting (`]r` / `[r`)

Every other occurrence of the identifier under the cursor lights up
automatically — illuminate-style, always on, no keypress needed. Refreshes
on `CursorHold` (the same idle-debounce every other "highlight after you
stop moving" plugin relies on) and clears immediately on `CursorMoved` so
nothing lingers stale while you're actively moving around.

- Scoped like mutation-site highlighting: the enclosing function if
  there is one, else the whole buffer — so a same-named local in an
  unrelated sibling function doesn't light up too.
- The occurrence under the cursor gets its own highlight
  (`TreesitterReferenceCurrent`: underline only, no background — the
  cursor already marks the spot) distinct from the others
  (`TreesitterReferenceOther`, linked to `IncSearch`, which is what's
  meant to catch your eye elsewhere).
- `]r` / `[r`: jump to the next/previous occurrence, following the same
  repeat-bracket conventions as the other structural motions in
  [navigation.md](./navigation.md).

## 󰘦 Ambient Code-Smell Diagnostics

A handful of structural checks run ambiently and surface through the
normal `vim.diagnostic` UI — gutter signs, virtual text, `<leader>d` — right
alongside LSP and `nvim-lint` diagnostics, not a separate system. Refreshes
on the same trigger set `nvim-lint` already uses (`CursorHold`,
`BufWritePost`, `InsertLeave`, see `plugins/coding.lua`), so both feel like
one cohesive "checked when you pause" experience rather than two different
cadences.

These are heuristics from the parse tree, not semantic analysis, so some
false positives are expected and accepted as a trade-off for not needing
an LSP or type information:

- **Empty catch/except block** (WARN) — nothing in its body, or a lone
  `pass` — silently swallows whatever it caught.
- **Too many parameters** (HINT) — a function, method, or constructor
  with more than 5 parameters.
- **Deeply nested conditionals/loops** (HINT) — more than 3 levels deep
  within one function. Only the node where nesting *first* crosses the
  threshold is flagged, not every level beyond it.
- **Missing catch-all arm** (HINT) — a `match`/`when`/`switch` with no
  `_`/`else`/`default` branch. Can't tell that a `when` over a sealed
  class/enum is already exhaustive at the language level, so it may flag
  matches that don't actually need one — hence HINT rather than WARN.
  `if`/`else` chains are deliberately not checked: an `if` with no `else`
  is common and usually intentional, not a smell.

The parameter-count and nesting-depth thresholds are fixed for now
(`utils/treesitter/diagnostics.lua`); if they turn out consistently too
noisy for a particular language/stack, that's the place to make them
configurable rather than a fixed default.

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

## 󰘦 Hunk Context Highlighting (`<leader>tg`)

Toggles a highlight (off by default) that pinpoints the exact token(s) a
git/jj diff hunk changed, layered on top of gitsigns' own sign column
rather than replacing it — so changing one string literal deep inside a
multi-line call highlights just that literal, not the raw changed line.

- Built directly on `gitsigns.nvim`'s own hunk data (`get_hunks()`), and,
  where available, its internal word-level diff — no separate diff
  computation of our own.
- Snaps the word-level diff to its smallest covering treesitter node (an
  identifier, a string literal, ...) when that's a snug fit. Falls back to
  the raw diffed characters when the smallest available node would be
  disproportionately wide — plain prose (Markdown, comments) has no
  treesitter node finer than a whole paragraph, since nothing subdivides
  continuous text into words, so highlighting the whole paragraph would be
  much less useful than highlighting just the changed words.
- Falls back further to highlighting the enclosing statement(s) when no
  word-level diff is possible at all (a pure addition, or a hunk that adds
  a different number of lines than it removes) — climbing until the
  parent becomes a block/statement-list, then stopping, so a change deep
  inside a function never highlights the whole function body. A hunk
  touching parts of two adjacent statements highlights both separately in
  this case, rather than their (possibly much wider) common ancestor.
- Stays in sync automatically: refreshes on gitsigns' `GitSignsUpdate`
  `User` autocommand (save, staging, external changes, ...).
- A pure deletion (no lines added, only removed) has no footprint in the
  current buffer, so it's skipped rather than highlighting some unrelated
  nearby line.
- Per-buffer toggle state — enabling it in one buffer doesn't affect
  others.

## Reusable building blocks

The above features share several small modules, kept generic on purpose so
a future feature can reuse them without re-deriving the same logic:

- `utils/treesitter/scope.lua`: a generic `find_enclosing(node, predicate)`
  climber (and a `matches_any(type, patterns)` substring-check helper) that
  the rest of this module's own function/class/block detection is built
  from — reusable by any feature that needs "the nearest ancestor
  matching X" for its own X, like the argument/parameter-list detection
  behind `<leader>Ca`. Also home to the function-like/class-like/block-like
  categorization (a declaration/definition/item node, not one of its
  substructures — a function's own body/parameter-list share its name but
  aren't it) and the "top-level statement within its nearest block" walk.
  Also has `node_at_line(bufnr, row)` (the node at a line's first
  non-blank column, nil for a blank line),
  `skip_leading_metadata(node)` (a declaration's real start, skipping any
  `@Annotation`/decorator/attribute above it),
  `find_signature_list(node)` (the argument/parameter list in a
  function/class's own signature, used by both `<leader>Ca` and the
  too-many-params diagnostic), and if/branch/arm/loop categorization
  (`is_if_node`, `is_branch_node`, `is_arm_node`, `is_loop_node`,
  `is_nesting_node`) shared by the fold summaries and the deep-nesting/
  missing-arm diagnostics — each requires an actual construct-shaped
  suffix (`starts_with_any`/`ends_with_any`), not just a prefix, since a
  bare anonymous keyword token (the literal `if`/`for` node inside its
  own `if_expression`/`for_statement`) or an arm-internal node (Kotlin's
  `when_entry`/`when_condition`) can share a prefix with the real
  construct without being one.
- `utils/treesitter/identifier.lua`: resolve "the identifier this node is
  really about" (e.g. the `count` in a `self.count` member access).
- `utils/treesitter/motion.lua`: move the cursor to the nearest of a list of
  nodes, relative to the cursor.
- `utils/treesitter/highlight.lua`: highlight a list of node ranges, with
  the highlight auto-clearing once the cursor leaves a given node's line
  range.
