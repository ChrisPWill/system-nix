# Plan: Domain-Owned Shell Integrations

**Priority:** 2

**Objective:** Move tool-specific shell bindings, abbreviations, and widgets out of `core/shells` and into the modules that own the tools.

## Rationale

`core/shells` should define shell behavior that is foundational: enabling shells, history, prompt basics, vi mode, default shell handoff, and universal navigation aliases.

It currently also owns bindings and abbreviations for Neovim, AI commit generation, Viddy, archive handling, media conversion, Nix workflow helpers, and Jujutsu. That makes `core` depend conceptually on higher-level domains and makes feature removal harder.

## Proposed Ownership

- `tv-nvim` widgets: `dev/editors/neovim`
- `ai-commit` widgets: `ai`
- `viddy` current-command widgets: `cli` or `cli/watch.nix`
- archive abbreviations: `cli/files.nix`
- image and video conversion abbreviations: `media/processing.nix`
- Jujutsu abbreviations: `dev/vcs`
- Nix flake workflow abbreviations: `dev` or a future `nix` development module

## Core Should Keep

- Shell enablement for Zsh, Fish, and Nushell.
- Shell history and completion behavior.
- Prompt configuration.
- Common directory navigation aliases.
- Default interactive shell handoff.

## Implementation Steps

1.  Identify each non-core shell binding and abbreviation in `core/shells`.
2.  Move each block to the owning domain module.
3.  Keep shell-specific syntax local to the owning module when the behavior is tool-specific.
4.  Leave shared shell infrastructure in `core/shells/shared.nix`.
5.  Rebuild and test the same interactions in Zsh, Fish, and Nushell.

## Success Criteria

- Removing a domain also removes that domain's shell integrations.
- `core/shells` contains only foundational shell configuration.
- Existing keybindings and abbreviations still work in enabled shells.
- The relevant Home Manager target evaluates and switches successfully.
