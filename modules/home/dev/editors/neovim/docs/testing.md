# 󰙨 Testing Lifecycle

This configuration uses `neotest` for Python, Rust, C++, Java, and Kotlin, providing an integrated test runner and summary view.

## 󰌌 Keybindings

| Key           | Action                         | Mode   |
| :------------ | :----------------------------- | :----- |
| `<leader>ctt` | **Test** Single (under cursor) | Normal |
| `<leader>cT`  | **Test** current **File**      | Normal |
| `<leader>ctw` | **Test Watch** (Toggle)        | Normal |
| `<leader>cts` | **Test Stop** (Hanging test)   | Normal |
| `<leader>tt`  | **Test Summary** (Toggle)      | Normal |

## 󰘦 Advanced Usage

- **Floating Results:** If a test fails, `neotest` provides a diagnostic line. Hover over it to see the error.
- **Adapters:**
  - **Python:** Using the standard `unittest` runner.
  - **Rust:** Integrated with `rustaceanvim` for cargo-aware testing.
  - **C++:** Using `neotest-ctest` for CMake-driven projects (assumes `build/` directory).
  - **Java/Kotlin:** Using `neotest-java` for JUnit and `neotest-gradle` for Gradle-based projects (supports Kotest via Gradle).
- **Log Level:** Currently set to **DEBUG** for troubleshooting test runner issues.
