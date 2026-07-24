# 󰗀 Language Support

Language plugins stay installed, while executable-backed features activate at
runtime. Enter the matching named devshell and launch `meow` from it; outside a
shell, missing LSPs and formatters are intentionally dormant. The complete
catalog and envoluntary workflow are in `../../../README.md`.

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
- **Kotlin:** Powered by JetBrains' alpha `kotlin-lsp`; IntelliJ EditorConfig rules are authoritative for LSP formatting and diagnostics.
- **Python:** Managed with `basedpyright` and `ruff`.

## 󰘦 Data & Documentation

- **GraphQL:** Dedicated LSP support.
- **Markdown:** Advanced rendering with `markview.nvim` and wiki-link diagnostics via `marksman`.
- **YAML:** Schema-aware diagnostics for GitHub Actions, Kubernetes, etc.
- **JSON:** Formatting and schema validation.
