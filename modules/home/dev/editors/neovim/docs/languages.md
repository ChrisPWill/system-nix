# 󰗀 Language Support

This configuration provides robust support for a wide range of development environments and tools.

## 󰙅 Shell Scripting

- **Fish:** Full support via `fish-lsp` and `fish_indent`.
- **Bash / Zsh:** Deep integration with `bash-language-server`, `shellcheck` for linting, and `shfmt` for formatting.
- **Dockerfile:** Syntax highlighting and structural navigation.

## 󰘦 System & Config Languages

- **Nix:** Powered by `nixd` and `alejandra`.
- **Rust:** Built using `rustaceanvim` for deep `rust-analyzer` and `cargo` integration.
- **TOML:** Managed via `tombi` for LSP, formatting, and project-wide coherence.
- **KDL:** Syntax support for Zellij and Niri configuration files.

## 󰘦 Web & Backend

- **TypeScript / JavaScript:** React (TSX/JSX) support with dedicated tools.
- **Tailwind CSS:** Integrated LSP and real-time color highlighting (`<leader>th`).
- **HTML / CSS:** Full LSP support including `jsonls` and `yamlls`.
- **Go:** Integrated via `gopls` with formatting and linting.
- **Java:** Robust support using `jdtls` and `google-java-format`.
- **Kotlin:** Powered by `kotlin-language-server` and `ktlint`.
- **Python:** Managed with `basedpyright` and `ruff`.

## 󰘦 Data & Documentation

- **GraphQL:** Dedicated LSP support.
- **Markdown:** Advanced rendering with `markview.nvim` and wiki-link diagnostics via `marksman`.
- **YAML:** Schema-aware diagnostics for GitHub Actions, Kubernetes, etc.
- **JSON:** Formatting and schema validation.
