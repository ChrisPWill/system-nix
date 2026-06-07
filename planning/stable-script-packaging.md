# Plan: Stable Script Packaging

**Objective:** Convert stable user scripts from raw `home.sessionPath` files into declared package-style commands with explicit dependencies.

## Core Requirements

- **Stable Scripts Only:** Start with deterministic, settled scripts. Do not include AI prompt or commit-generation scripts yet.
- **Explicit Dependencies:** Each packaged command should declare the binaries it calls.
- **Preserve Command Names:** Existing commands such as `repo-root` and `toggle-pinned` should remain available under the same names.
- **Low Behavior Change:** The first pass should package scripts, not redesign their behavior.

## Stable Initial Scope

- `repo-root`
- `repo-name`
- `open-vcs`
- `tv-nvim`
- `test-iso-vm`
- `toggle-pinned`

## Out of Scope For First Pass

- `ai-ask`
- `ai-commit`

These depend on prompt design, model behavior, and interactive retry UX. They can be packaged later after their interfaces settle.

## Proposed Architecture

1.  **Script Package Module:**
    - Add a module in the relevant domain, likely `modules/home/core/scripts.nix` or `modules/home/cli/scripts.nix`.
    - Use `pkgs.writeShellApplication` where the implementation is shell-compatible.
    - For Nushell scripts, either wrap `nu <script>` with declared runtime inputs or use a small packaging helper.
2.  **Dependency Attachment:**
    - `repo-root`: `jj`, `git`
    - `open-vcs`: `lazyjj`, `lazygit`, `repo-root`
    - `tv-nvim`: `television`, `neovim`
    - `test-iso-vm`: `nix`, `qemu`
    - `toggle-pinned`: `nushell`, `niri`, `omniwmctl`, `osascript` on Darwin where applicable
3.  **PATH Transition:**
    - Keep `home.sessionPath` temporarily during migration if needed.
    - Remove or narrow it once stable scripts are packaged.

## Implementation Steps

1.  Create a packaging helper for Nushell scripts.
2.  Package the stable initial scope with explicit dependencies.
3.  Add the generated packages to `home.packages`.
4.  Update keybinds or aliases only if paths currently assume `${config.homeModuleDir}/scripts`.
5.  Remove stable commands from reliance on the raw script directory.

## Success Criteria

- Stable script commands are available from `PATH` after rebuilding the relevant NixOS or Darwin flake target.
- Running each stable command still behaves as before.
- Dependencies are declared with the command rather than implied by unrelated modules.
- AI scripts remain untouched in the first pass.
