#  Overridden Standard Neovim Keybindings

This document tracks standard Neovim mappings that are currently overridden by this configuration's **Hybrid Philosophy** (Helix-style navigation and specialized tools).

## 1. The `g` (Goto) Mode Overrides

These keys no longer perform their native Neovim actions as they have been redirected to spatial navigation or pickers.

| Key  | Native Neovim Action        | Alternative Key | Alternative Command         |
| :--- | :-------------------------- | :-------------- | :-------------------------- |
| `gh` | Enter **Select Mode**       | None            | `:set selectmode`           |
| `gs` | **Sleep** (wait N seconds)  | None            | `:sleep`                    |
| `ge` | **Backward to end of word** | None            | None                        |
| `gt` | **Next Tab**                | `<leader>]t`    | `:tabnext`                  |
| `gc` | **Commenting** (0.10+)      | `Ctrl-C`        | `:lua MiniComment.toggle()` |
| `ga` | **Show ASCII value**        | None            | `:ascii`                    |
| `gm` | **Middle of screen line**   | `gM`            | None                        |
| `gn` | **Search forward & select** | `Alt-n`         | None                        |
| `gp` | **Put and leave cursor**    | None            | `:put`                      |

## 2. Mark 'm' Overrides

The `m` key is the standard "Set Mark" operator. The following specific sequences are overridden by specialized tools, though other marks (e.g., `mb`, `mc`, `mj`) remain available.

| Key  | Native Neovim Action | Custom Action                 |
| :--- | :------------------- | :---------------------------- |
| `mm` | Set mark `m`         | **Match bracket** (`%`)       |
| `ms` | Set mark `s`         | **Add Surround**              |
| `md` | Set mark `d`         | **Delete Surround**           |
| `mr` | Set mark `r`         | **Replace Surround**          |
| `mf` | Set mark `f`         | **Find Surround**             |
| `mh` | Set mark `h`         | **Highlight Surround**        |
| `mn` | Set mark `n`         | **Surround (Update n lines)** |
| `ma` | Set mark `a`         | **Align (Regex)**             |
| `mA` | Set mark `A`         | **Align (Interactive)**       |

## 3. Visual Search Overrides

Standard Neovim `*` and `#` in Visual mode search for the word under the cursor. This config overrides them with a more powerful selection-based search.

| Key | Native Neovim Action     | New Action                      |
| :-- | :----------------------- | :------------------------------ |
| `*` | Search word under cursor | **Search the actual selection** |
| `#` | Search word backward     | **Search selection backward**   |

---

_To restore a native mapping, use `vim.keymap.del` or overwrite the custom mapping in `lua/keymaps.lua`._
