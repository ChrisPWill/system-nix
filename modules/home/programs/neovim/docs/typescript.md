# 󰛦 TypeScript & Deno

This configuration dynamically switches between Node.js and Deno based on the project root.

## 󰘦 Multi-Runtime Support

- **Node.js:** Active when no `deno.json` is present. Uses `typescript-tools.nvim`.
- **Deno:** Active when `deno.json` is found. Uses `denols`.

## 󰌌 Keybindings (Node.js Only)

| Key | Action | Plugin |
| :--- | :--- | :--- |
| `<leader>cio` | **Organize Imports** | TSTools |
| `<leader>cis` | **Sort Imports** | TSTools |
| `<leader>cim` | **Add Missing Imports** | TSTools |
| `<leader>cxa` | **Fix All** | TSTools |
| `<leader>cFe` | **Rename File** | TSTools |
| `<leader>cFr` | **File References** | TSTools |

## 󰘦 Linting & Formatting

- **Linting:** Using `eslint_d` for Node and `deno` for Deno.
- **Formatting:** 
    - **Node:** Prioritizes `prettierd`.
    - **Deno:** Uses `deno_fmt`.
    - Both use `treefmt` if a configuration is found.
- **Diagnostics:** Hover with `K` to see the error, and use `<leader>/d` to see the buffer's diagnostics.
