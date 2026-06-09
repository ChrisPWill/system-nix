# Plan: Development Language Toolchain Extraction

**Priority:** 5

**Objective:** Move shared language-server and formatter packages out of `dev/editors` into a dedicated development language toolchain module.

## Rationale

`dev/editors/lsps.nix` is currently shared by Helix and Cursor, and it overlaps conceptually with Neovim and Claude Code language-server configuration. The module is not editor-specific. It represents the user's baseline development language toolchain.

Putting it under a neutral domain makes the dependency clearer and creates a future place for shared language metadata.

## Proposed Layout

```text
modules/home/dev/languages/
  default.nix
  packages.nix
```

Optional future split:

```text
modules/home/dev/languages/
  nix.nix
  python.nix
  rust.nix
  go.nix
  lua.nix
  web.nix
  shell.nix
  cpp.nix
  markdown.nix
  kotlin.nix
```

## Initial Scope

- Move `dev/editors/lsps.nix` to `dev/languages/packages.nix`.
- Import `dev/languages` from `dev/default.nix`.
- Remove editor-local imports of `../lsps.nix` and `./lsps.nix`.

## Future Scope

- Share language metadata between Helix, Neovim, and Claude Code where practical.
- Avoid forcing every consumer to use the same config shape too early.
- Keep Neovim nixCats packaging intact unless duplication becomes a real maintenance burden.

## Implementation Steps

1.  Create `dev/languages/default.nix`.
2.  Move `dev/editors/lsps.nix` to `dev/languages/packages.nix`.
3.  Import `./languages` from `dev/default.nix`.
4.  Remove LSP package imports from Helix and Cursor modules.
5.  Verify Helix, Cursor, Neovim, and Claude Code still have required binaries available.

## Success Criteria

- Language-server packages are installed from a neutral `dev/languages` module.
- Editors no longer own shared language package installation.
- Existing editor configuration still evaluates.
- Future language additions have an obvious home.
