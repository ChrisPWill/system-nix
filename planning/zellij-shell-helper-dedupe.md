# Plan: Zellij Shell Helper Deduplication

**Objective:** Reduce duplicated Zellij helper logic across Fish, Zsh, and Nushell while preserving the existing command UX.

## Core Requirements

- **Preserve Commands:** Existing helpers such as `zz`, `za`, `zr`, `zrf`, `zl`, `zk`, `zka`, `zd`, `zda`, and `edit` should continue to work.
- **One Behavioral Implementation:** Shared logic, especially `edit`, should live in one command rather than three shell-specific functions.
- **Shell-Friendly Wrappers:** Shell aliases should remain thin and ergonomic.
- **No Multiplexer Setting Changes:** Keep existing Zellij settings and layout symlink behavior.

## Proposed Architecture

1.  **Shared Scripts:**
    - Add packaged helper commands such as `zellij-session`, `zellij-attach`, and `zellij-edit`, or a single command with subcommands.
    - Use stable script packaging infrastructure if that plan is implemented first.
2.  **Thin Shell Config:**
    - Map Fish, Zsh, and Nushell aliases/functions to the shared helper commands.
    - Keep shell-specific syntax minimal.
3.  **Domain Ownership:**
    - Keep this inside `modules/home/dev/multiplexer` because the behavior is tool-specific.

## Implementation Steps

1.  Decide whether helpers should be one command with subcommands or several small commands.
2.  Implement shared helper command(s), including repo-name fallback for `edit`.
3.  Replace duplicated Fish/Zsh/Nushell function bodies with aliases or tiny wrappers.
4.  Keep Zellij settings and layout config unchanged.
5.  Verify each helper in all enabled shells.

## Success Criteria

- The duplicated shell function bodies disappear from `modules/home/dev/multiplexer/default.nix`.
- `edit` has one implementation of repo-name fallback behavior.
- Existing aliases still work in Fish, Zsh, and Nushell.
- The relevant NixOS or Darwin system flake target builds, matching the target used by `nixos-rebuild` or `darwin-rebuild`.
