# 󰊢 Git & VCS Workflow

Integrated VCS with `gitsigns`, `lazygit`, and your custom **Koji** conventional commit helper.

## 󰘦 Gitsigns (Hunk Management)

| Key | Action | Mode |
| :--- | :--- | :--- |
| `]g` / `[g` | **Next/Prev** Hunk | Normal/Visual |
| `<leader>gs` | **Stage** Hunk | Normal/Visual |
| `<leader>gr` | **Reset** Hunk | Normal/Visual |
| `<leader>gp` | **Preview** Hunk | Normal |
| `<leader>gb` | **Blame** Line | Normal |
| `<leader>gd` | **Diff** against Index | Normal |

## 󰘦 Committing with Koji

When you open a `gitcommit` or `jjdescription` buffer:
- **Automatic Trigger:** Koji will attempt to run automatically.
- `<leader>k`: Manual **Run Koji** to insert a conventional commit message.
- **Insert Mode:** You will be automatically placed in insert mode to interact with Koji.

## 󰘦 External Tools

- `<leader>_`: Open **Lazygit** (Snacks.lazygit).
- `<leader>j`: Open **LazyJJ** (Snacks.terminal).
- `<leader>ggb`: Open **Tig Blame** for the current file.
- `<leader>ggg`: **Open in Browser** (GitHub/Lab permalink).
