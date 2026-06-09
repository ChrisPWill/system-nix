# Plan: Domain-Owned Scripts

**Priority:** 1

**Objective:** Move user scripts out of the top-level `modules/home/scripts` directory and into the domains that own their behavior.

## Rationale

`modules/home/scripts` is currently a convenience directory, but Blueprint exports direct children of `modules/home` as Home Manager modules. That makes `homeModules.scripts` appear as if it were a real module even though it only contains executables.

The current global script path also hides ownership. Scripts such as `ai-commit`, `tv-nvim`, `repo-root`, and `toggle-pinned` are maintained by different domains, but all live in the same untyped bucket.

## Current Ownership Map

- `ai-ask`: `ai`
- `ai-commit`: `ai`
- `repo-root`: `dev/vcs`
- `repo-name`: `dev/vcs`
- `open-vcs`: `dev/vcs`
- `tv-nvim`: `dev/editors/neovim`
- `toggle-pinned`: `desktop/wm`
- `test-iso-vm`: `ops` or a future NixOS installer/testing domain

## Proposed Layout

```text
modules/home/ai/scripts/ai-ask
modules/home/ai/scripts/ai-commit
modules/home/dev/vcs/scripts/repo-root
modules/home/dev/vcs/scripts/repo-name
modules/home/dev/vcs/scripts/open-vcs
modules/home/dev/editors/neovim/scripts/tv-nvim
modules/home/desktop/wm/scripts/toggle-pinned
modules/home/ops/scripts/test-iso-vm
```

## Implementation Steps

1.  Move scripts to their owning domains without changing behavior.
2.  Replace `${config.homeModuleDir}/scripts` references with domain-specific paths.
3.  Add each required script directory to `home.sessionPath` from the owning module.
4.  Update Nushell path handling to use the same domain-owned script directories.
5.  Remove the top-level `modules/home/scripts` directory after all references are gone.

## Success Criteria

- `nix eval .#homeModules --apply builtins.attrNames --json` no longer includes `scripts`.
- Existing command names still resolve from `PATH`.
- Window-manager keybinds, shell widgets, and VCS helpers still call the same commands.
- Script source location clearly matches domain ownership.
