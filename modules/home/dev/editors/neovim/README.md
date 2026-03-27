#  Neovim Configuration (meow)

This is a modular Neovim configuration managed via [nixCats](https://github.com/BirdeeHub/nixCats-nvim), providing a robust development environment with a focus on speed, reliability, and editor-agnostic navigation.

## 󰙅 Structure

The configuration is split into logical modules under `lua/` to keep `init.lua` concise and maintainable.

```text
.
├── default.nix            # Nix derivation and plugin management
├── config/                # Neovim configuration (lua, init.lua, snippets)
│   ├── init.lua           # Entry point: sets up global state and loads modules
│   └── lua/
│       ├── utils.lua      # Shared helper functions (nmap, project checks)
│       ├── autocmds.lua   # Autocommands (Diagnostics, Koji terminal, etc.)
│       ├── keymaps.lua    # Global keybindings (see docs/KEYMAPS.md)
│       ├── global-options.lua # Vim options (shiftwidth, relativenumber, etc.)
│       ├── snacks-config.lua  # Configuration for snacks.nvim (picker, etc.)
│       └── plugins/       # Plugin specifications (loaded via lze)
│           ├── init.lua   # Plugin entry point: consolidated specification loader
│           ├── ai.lua     # Copilot, Minuet, Avante
│           ├── coding.lua # Grug-far, Linting, Formatting
│           ├── completion.lua # blink.cmp, Luasnip, Scissors
│           ├── debug.lua  # nvim-dap and language adapters
│           ├── navigation.lua # Arrow, Leap
│           ├── test.lua   # neotest
│           ├── treesitter.lua # nvim-treesitter, textobjects, and Treewalker
│           ├── ui.lua     # lualine, which-key, mini.nvim, markview
│           ├── vcs.lua    # gitsigns
│           └── lsp/
│               ├── init.lua    # lsp_on_attach logic
│               └── servers.lua # Individual LSP server configurations
└── docs/                  # Personal Knowledge Base (Markdown reference guides)
```

## 󰌌 Keybindings

This configuration follows a **Hybrid Philosophy** designed to reduce friction when switching between Neovim and Helix while preserving the strength of both.

### Core Rules
- **Hybrid Navigation:** Retains Neovim's native **Operator-Pending** model while adopting Helix `g` (Goto), `m` (Match/Surround), and Space (`<leader>`) modes.
- **Helix Alignment:** `g` prefix for movement (e.g., `gh` for line start, `gl` for line end, `ge` for end of file).
- **Functionality-Focused Descriptions:** All keybinding descriptions (`desc`) MUST describe *what* the action does, not *which plugin* provides it (e.g., "Explorer" instead of "Snacks Explorer").
- **Domain-Specific Grouping:** Organise keybindings into functional domains (e.g., `<leader>g` for Git, `<leader>t` for Toggles, `<leader>r` for Refactoring).

### Knowledge Base & Documentation
- **Maintenance:** When adding complex plugins or modifying significant workflows, **ALWAYS** update or create a corresponding reference guide in `docs/`.
- **Cheatsheet:** Keep `docs/cheatsheet.md` up to date as the primary entry point for common flows.
- **Minimalist Documentation:** Guides should focus on practical use-cases and keybindings. Remove technical implementation details (like "Floating Window") and use standard mode abbreviations (e.g., `(n/x/o)`).

## 󱄅 Nix Integration

The configuration is integrated into the NixOS/Darwin system via `nixCats`. This allows for:
- **Category-based plugin loading:** Plugins and LSPs are enabled/disabled based on categories defined in `default.nix`.
- **Runtime Dependencies:** LSPs and tools like `ripgrep`, `fd`, and `stylua` are automatically provided by Nix.
- **OutOfStoreSymlinks:** The configuration is symlinked to allow for rapid iteration without full Nix rebuilds.

## 󰲎 Loading Logic

We use [lze](https://github.com/BirdeeHub/lze) for high-performance lazy loading. Each file in `lua/plugins/` returns a list of specifications that are merged and loaded by `lua/plugins/init.lua`. This ensures that Neovim starts instantly while still providing a rich feature set on demand.
