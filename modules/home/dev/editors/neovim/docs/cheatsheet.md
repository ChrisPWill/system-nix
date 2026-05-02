#  Neovim Custom Features Cheat-sheet

This configuration uses a **Hybrid Philosophy** (Helix-inspired navigation + Neovim power).

## 󰌌 Essential Custom Mappings

| Key             | Action                                 |
| :-------------- | :------------------------------------- |
| `Ctrl-C`        | **Comment Line / Selection**           |
| `Ctrl-Alt-J/K`  | **Move Selection Down / Up**           |
| `Alt-n / Alt-N` | **Search & Select Next / Prev**        |
| `gn / gp`       | **Next / Prev Buffer**                 |
| `[t / ]t`       | **Next / Prev Tab**                    |
| `-`             | **Explorer**                           |
| `Ctrl-\`        | **Terminal**                           |
| `\`             | **Jump to characters**                 |
| `;`             | **Jump to marked line**                |
| `<leader>;`     | **Jump to marked file**                |
| `ms / md / mr`  | **Add / Delete / Replace Surround**    |
| `mf / mh / mn`  | **Find / Highlight / Update Surround** |
| `ma`            | **Align (Regex)**                      |
| `mA`            | **Align (Interactive)**                |

## 󰘦 Git Group (<leader>g)

| Key                 | Action                     |
| :------------------ | :------------------------- |
| `<leader>gg`        | **LazyGit**                |
| `<leader>gj`        | **Jujutsu (LazyJJ)**       |
| `<leader>gb`        | **Tig Blame**              |
| `<leader>gl`        | **Blame Line (Inline)**    |
| `<leader>go / gO`   | **Open in Browser**        |
| `<leader>gs / gr`   | **Stage / Reset hunk**     |
| `<leader>gd / gD`   | **Diff (Index / Commit)**  |
| `<leader>gtb / gtd` | **Toggle Blame / Deleted** |

## 󰘦 Toggles & UI (<leader>t / <leader>u)

| Key               | Action                    |
| :---------------- | :------------------------ |
| `<leader>td`      | **In-buffer Diagnostics** |
| `<leader>tf`      | **Autoformat**            |
| `<leader>tm`      | **Markview**              |
| `<leader>th`      | **Highlight Colors**      |
| `<leader>tx`      | **Diagnostics (Trouble)** |
| `<leader>ts`      | **Symbols (Trouble)**     |
| `<leader>tl`      | **LSP (Trouble)**         |
| `<leader>tq / tL` | **Quickfix / Loclist**    |
| `<leader>un`      | **Dismiss Notifications** |

## 󰘦 Global Search & Pickers

| Key          | Action                    |
| :----------- | :------------------------ |
| `<leader>f`  | **Find Files**            |
| `<leader>gf` | **Find Git Files**        |
| `<leader>F`  | **Smart Find**            |
| `<leader>b`  | **Search Buffers**        |
| `<leader>d`  | **Buffer Diagnostics**    |
| `<leader>D`  | **Workspace Diagnostics** |
| `<leader>s`  | **Document Symbols**      |
| `<leader>S`  | **Workspace Symbols**     |
| `<leader>a`  | **Code Actions**          |

## 󰘦 Refactor & Replace (<leader>r)

| Key          | Action                           |
| :----------- | :------------------------------- |
| `<leader>rn` | **Rename Symbol**                |
| `<leader>rr` | **Search & Replace**             |
| `<leader>rw` | **Replace Word**                 |
| `<leader>ra` | **Structural Search**            |
| `<leader>rf` | **Replace in File**              |
| `<leader>rs` | **Replace from Search Register** |
| `<leader>rv` | **Replace Selection (x)**        |

## 󰘦 Search / Pick Group (<leader>/)

| Key          | Action                    |
| :----------- | :------------------------ |
| `<leader>/t` | **Find Class / [t]ype**   |
| `<leader>/k` | **[k]nowledge Base**      |
| `<leader>/K` | **[K]nowledge (Grep)**    |
| `<leader>/;` | **Marks (;)**             |
| `<leader>/m` | **Key[m]aps**             |
| `<leader>/h` | **[h]elp Pages**          |
| `<leader>/l` | **[l]ocation List**       |
| `<leader>/M` | **[M]an Pages**           |
| `<leader>/q` | **[q]uickfix List**       |
| `<leader>/R` | **[R]esume last picker**  |
| `<leader>/u` | **[u]ndo History**        |
| `<leader>//` | **Grep Search**           |
| `<leader>/w` | **Grep [w]ord/selection** |
| `<leader>/j` | **[j]umps**               |
| `<leader>/s` | **[s]ymbols (Buffer)**    |
| `<leader>/S` | **[S]ymbols (Workspace)** |

## 󰘦 Knowledge & Snippets Group (<leader>k)

| Key          | Action                     |
| :----------- | :------------------------- |
| `<leader>kc` | **Cheat-sheet**            |
| `<leader>km` | **Keymaps Guide**          |
| `<leader>kr` | **Neovim Quickref**        |
| `<leader>ks` | **Search / Edit Snippets** |
| `<leader>ka` | **Add Snippet (n/x)**      |

## 󱄅 Detailed Guides

Find more info in these dedicated reference guides (Browse with `<leader>/k`):

- **[KEYMAPS.md](./KEYMAPS.md):** Core mapping philosophy.
- **[lsp.md](./lsp.md):** LSP navigation, definitions, and code actions.
- **[refactoring.md](./refactoring.md):** Structural edits and search/replace.
- **[navigation.md](./navigation.md):** Movement and navigation tools.
- **[vcs.md](./vcs.md):** Git workflow and Jujutsu integration.
- **[snippets.md](./snippets.md):** Managing and using Snippets.
- **[testing.md](./testing.md):** Integrated test runner.
- **[languages.md](./languages.md):** Comprehensive language support.
- **[rust.md](./rust.md) / [typescript.md](./typescript.md) / [nix.md](./nix.md):** Language-specific tools.
- **[README.md](../README.md):** Architectural overview.
