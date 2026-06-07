# Plan: Formatter Configuration Unification

**Objective:** Make formatter behavior consistent across `nix fmt`, formatter packages, and formatting checks.

## Core Requirements

- **Single Source of Truth:** Avoid maintaining three divergent formatter definitions.
- **Working TOML/Kotlin Setup:** Remove or fix the missing absolute-path `ktlint.editorconfig` reference in `treefmt.toml`.
- **Check Parity:** The formatting check should cover the same relevant formatters as the formatter wrapper.
- **Fixture Safety:** Preserve the Neovim LSP fixture exclusions.

## Current Issues

- `formatter.nix` enables `ktlint`, but `checks/formatting.nix` does not.
- `treefmt.toml` includes `tombi` and Kotlin configuration, but the Nix treefmt modules have TOML formatting commented out.
- `treefmt.toml` points to `/home/cwilliams/.system-nix/modules/home/dev/editors/neovim/ktlint.editorconfig`, which does not exist and is not portable to macOS.

## Proposed Architecture

1.  **Prefer Nix-Defined Treefmt:**
    - Put formatter definitions in one Nix helper module or shared expression.
    - Reuse it from both `formatter.nix` and `checks/formatting.nix`.
2.  **Treat `treefmt.toml` As Optional:**
    - Either remove it if treefmt-nix owns the config fully, or reduce it to documentation-compatible settings that do not conflict with the Nix definitions.
3.  **Portable Kotlin Formatting:**
    - Add a real repository-local Kotlin editorconfig if needed.
    - Reference it through treefmt-nix settings rather than an absolute host path.

## Implementation Steps

1.  Create a shared formatter expression, for example `modules/dev/formatting/treefmt.nix` or `checks/treefmt-module.nix`.
2.  Reuse that expression in `formatter.nix` and `checks/formatting.nix`.
3.  Decide whether to remove `treefmt.toml` or make it match the Nix definition exactly.
4.  Fix Kotlin formatter configuration by adding a checked-in editorconfig or dropping the custom option.
5.  Add TOML formatting through `tombi` if it is still desired.

## Success Criteria

- `nix fmt` and the formatting check use the same formatter set.
- No formatter references absolute machine-specific paths.
- Formatting excludes `modules/home/dev/editors/neovim/tests/fixtures/**`.
- The generated formatting check target builds, for example `.#checks.<system>.formatting`, or the full `nix flake check` passes.
