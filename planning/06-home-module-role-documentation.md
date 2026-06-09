# Plan: Home Module Role Documentation

**Priority:** 6

**Objective:** Document the difference between Home Manager domains and top-level role/profile modules.

## Rationale

`modules/home/README.md` describes domain directories, but the top level also contains non-domain modules:

- `home-shared.nix`
- `personal-machine.nix`
- `standalone.nix`
- `graphical-nixos`

These are valid orchestration or role modules, but they are not domains in the same sense as `dev`, `desktop`, `ai`, or `knowledge`. Making that distinction explicit will help future changes land in the right place.

## Proposed Documentation Structure

Add a section to `modules/home/README.md`:

```markdown
## Top-Level Module Types

- Domains: imported by `home-shared.nix` and organized by user intent.
- Roles: optional high-level toggles or overlays imported by hosts.
- Compatibility wrappers: stable module names that preserve host imports while internal layout evolves.
```

## Module Classification

- `home-shared.nix`: universal Home Manager profile and domain orchestrator.
- `personal-machine.nix`: role toggle for personal-only packages and settings.
- `standalone.nix`: standalone Home Manager support for non-NixOS or non-Darwin use.
- `graphical-nixos`: optional graphical NixOS role, eventually a wrapper around `desktop` modules.

## Implementation Steps

1.  Update `modules/home/README.md` with a short role/profile section.
2.  Clarify that only domain directories should contain normal tool configuration.
3.  Note that top-level role modules should remain thin and primarily compose domains.
4.  Update examples if any future moves introduce compatibility wrappers.

## Success Criteria

- The README explains why some top-level files are not domains.
- Future contributors can tell whether a change belongs in a domain or a role.
- Compatibility wrappers can exist without weakening the intent-based domain structure.
