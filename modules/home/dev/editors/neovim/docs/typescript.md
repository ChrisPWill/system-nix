# 󰛦 TypeScript, React & Deno

This configuration dynamically switches between Node.js and Deno based on the project root.

Launch `meow` from `nd node22` or `nd node24`. Node, TypeScript, web servers,
formatters, linters, and the JavaScript debugger are supplied by that shell.

## 󰘦 Multi-Runtime Support

- **Node.js:** Active when no `deno.json` is present. Uses `typescript-tools.nvim`.
- **Deno:** Active when `deno.json` is found. Uses `denols`.
- **React:** Support for `.tsx` and `.jsx` with Treesitter and standard LSP features.
- **Tailwind CSS:** Deep integration via `tailwindcss-language-server` and real-time color highlighting.

## 󰘦 Toggles & Styling

- **Highlight Colors:** Toggle at `<leader>th`. Displays CSS and Tailwind colors directly in the code.

## 󰌌 Keybindings (Node.js Only)

| Key           | Action                  | Plugin  |
| :------------ | :---------------------- | :------ |
| `<leader>cio` | **Organize Imports**    | TSTools |
| `<leader>cis` | **Sort Imports**        | TSTools |
| `<leader>cim` | **Add Missing Imports** | TSTools |
| `<leader>cxa` | **Fix All**             | TSTools |
| `<leader>cFe` | **Rename File**         | TSTools |
| `<leader>cFr` | **File References**     | TSTools |

## 󰘦 Linting & Formatting

- **Linting:** Using `eslint_d` for Node and `deno` for Deno.
- **Formatting:**
  - **Node:** Prioritizes `prettierd`.
  - **Deno:** Uses `deno_fmt`.
- **Diagnostics:** Hover with `K` to see the error, and use `<leader>/d` to see the buffer's diagnostics.
