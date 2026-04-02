# C++ Template

A modern C++ template managed with Nix and [Blueprint](https://github.com/numtide/blueprint).

## Getting Started

1.  **Initialize the project:**
    If you're using `direnv`, just `cd` into the directory and run `direnv allow`.
    Otherwise, run `nix develop`.

2.  **Build the project:**

    ```bash
    just build
    ```

3.  **Run the project:**
    ```bash
    just run
    ```

## Renaming the Project

To rename the project from `my_project` to your desired name, you can use a search-and-replace tool or run:

```bash
grep -rl "my_project" . | xargs sed -i "s/my_project/your_new_name/g"
```

## Adding Dependencies

To add a new library dependency (e.g., `fmt`):

1.  **Update Nix configuration:**
    Edit `nix/packages/default.nix` and `nix/devshells/default.nix` to add the package to `buildInputs`.

    ```nix
    buildInputs = with pkgs; [
      fmt
    ];
    ```

2.  **Update CMake configuration:**
    Edit `CMakeLists.txt` to find and link the library.

    ```cmake
    find_package(fmt REQUIRED)
    target_link_libraries(my_project PRIVATE fmt::fmt)
    ```

3.  **Update the lockfile:**
    If you added a new input to `flake.nix` (rare for standard libraries available in `nixpkgs`), or to ensure your environment is up-to-date:
    ```bash
    nix flake update
    ```

## Project Structure

- `src/`: Source files.
- `nix/`: Nix configuration files (packages, devshells, checks).
- `flake.nix`: Entry point for Nix.
- `justfile`: Command runner (shortcuts for common tasks).
- `treefmt.toml`: Formatter configuration.
- `.clang-tidy`: Static analysis configuration.
