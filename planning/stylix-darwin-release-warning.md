# Plan: Stylix Darwin Release Warning Cleanup

**Objective:** Resolve the Stylix/nix-darwin release mismatch warning that appears during flake evaluation.

## Core Requirements

- **No Noisy Evaluation Warning:** `nix flake show` and normal evaluations should not emit the Stylix/nix-darwin mismatch warning.
- **Explicit Decision:** Either align inputs or intentionally disable the release check with documentation.
- **No Theme Regression:** Preserve the current theme behavior on NixOS, Darwin, and Home Manager.

## Proposed Options

1.  **Align Inputs:**
    - Update or pin `stylix` and `nix-darwin` so their expected release versions match.
    - Prefer this if it does not force unrelated breakage.
2.  **Documented Suppression:**
    - Add `stylix.enableReleaseChecks = false;` only if the mismatch is accepted.
    - Document why the mismatch is acceptable and when to revisit it.

## Implementation Steps

1.  Inspect the current `flake.lock` versions for `stylix`, `nix-darwin`, and followed `nixpkgs`.
2.  Try an input alignment strategy first.
3.  Build the Darwin and NixOS system flake targets after alignment.
4.  If alignment is not practical, add the explicit Stylix release-check override in the shared theming module.
5.  Update docs or module comments with the chosen rationale.

## Success Criteria

- `nix flake show` no longer reports the Stylix/nix-darwin mismatch warning.
- Darwin and NixOS system build targets still pass.
- The decision is visible in code or documentation.
