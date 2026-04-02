# 󰘦 Snippets Guide

Manage and use code snippets effectively.

## 󰘦 Usage (Blink.cmp)

Snippets are integrated directly into the `blink.cmp` completion menu.

- **Trigger:** Type a snippet prefix (e.g., `unittest_class` in Python).
- **Select:** Use the completion menu to select the snippet.
- **Accept:** `Ctrl-e` (select and accept) or `Enter`.

## 󰘦 Navigation (Luasnip)

Once a snippet is expanded, use these to jump through placeholders:

- `Ctrl-L`: **Jump Forward** to the next placeholder.
- `Ctrl-J`: **Jump Backward** to the previous placeholder.

## 󰙅 Management (Scissors)

Access via the `<leader>k` group for high-speed snippet editing:

- `<leader>ks`: **Search / Edit** existing snippets. Opens a picker to select a snippet to modify.
- `<leader>ka`: **Add New** snippet.
  - _Tip:_ Select code in **Visual Mode** before pressing `<leader>ka` to prefill the snippet body.

## 󱄅 Storage & Customization

- **Snippet Directory:** Stored in `config/snippets/`.
- **Format:** VS Code-style JSON snippets are managed automatically by Scissors.
- **Manual Lua Snippets:** Can be added to `config/snippets/*.lua` (loaded via Luasnip).
- **Reloading:** Use `:LuaSnipReload` if you manually edit files.
