# 󰙨 Testing Lifecycle

This configuration uses `neotest` for Python, Rust, and C++, providing an integrated test runner and summary view.

## 󰌌 Keybindings

| Key           | Action                         | Mode   |
| :------------ | :----------------------------- | :----- |
| `<leader>ctt` | **Test** Single (under cursor) | Normal |
| `<leader>cT`  | **Test** current **File**      | Normal |
| `<leader>cts` | **Test Stop** (Hanging test)   | Normal |

## 󰘦 Advanced Usage

- **Floating Results:** If a test fails, `neotest` provides a diagnostic line. Hover over it to see the error.
- **Adapters:**
  - **Python:** Using the standard `unittest` runner.
  - **Rust:** Integrated with `rustaceanvim` for cargo-aware testing.
  - **C++:** Using `neotest-ctest` for CMake-driven projects (assumes `build/` directory).
- **Log Level:** Currently set to **DEBUG** for troubleshooting test runner issues.
