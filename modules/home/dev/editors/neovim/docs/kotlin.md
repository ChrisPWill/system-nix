# 󱘗 Kotlin Support

Kotlin support built around JetBrains' official, IntelliJ-based language server.

## 󰘦 Features

- **LSP:** Powered by JetBrains' official `kotlin-lsp` via `nvim-lspconfig`.
- **Formatting:** Routed through the LSP by `conform.nvim`, using IntelliJ's code-style engine and EditorConfig support.
- **Diagnostics:** Kotlin compiler diagnostics and IntelliJ inspections come from the LSP.
- **Tree-sitter:** Syntax highlighting and structural navigation are always enabled.

The official server is currently alpha software. It is used here because its IntelliJ formatter understands both generic EditorConfig properties and IntelliJ-specific `ij_kotlin_*` properties. The closest applicable `.editorconfig` takes precedence, including files outside Kotlin source roots.

Launch `meow` from `nd jvm`. The shell supplies JDK 21, Kotlin tooling, JDTLS,
and the Java formatter; project Gradle wrappers remain authoritative.

There is deliberately no editor-side `ktlint` formatter or `nvim-lint` check for Kotlin, so it cannot contradict IntelliJ EditorConfig rules. Projects can still run repository-native Gradle tasks such as ktlint or detekt independently, including in CI.

## 󰘦 Keybindings

Standard LSP keybindings apply for Kotlin:

| Key          | Action                  | Mode   |
| :----------- | :---------------------- | :----- |
| `<leader>cf` | **Format** code         | Normal |
| `K`          | **Hover** Documentation | Normal |
| `gd`         | **Go to Definition**    | Normal |
| `gr`         | **Go to References**    | Normal |
| `<leader>ca` | **Code Actions**        | Normal |
| `<leader>rn` | **Rename** Symbol       | Normal |

## 󱄅 Configuration

The Kotlin integration is packaged but remains dormant until `kotlin-lsp` is
executable in the editor's startup environment.
