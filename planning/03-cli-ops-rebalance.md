# Plan: CLI And Ops Rebalance

**Priority:** 3

**Objective:** Rebalance `cli` and `ops` so daily terminal UX lives under `cli`, while `ops` stays focused on administration, secrets, sync, and observability.

## Rationale

The current `ops` domain contains true operational tooling, but also file/archive UX and search/discovery tools. Those tools are part of daily command-line ergonomics and fit better beside the existing `cli/modern-unix.nix` module.

This keeps `ops` from becoming a catch-all for any non-development terminal package.

## Proposed `cli` Layout

```text
modules/home/cli/
  default.nix
  essentials.nix
  files.nix
  search.nix
  watch.nix
```

- `essentials.nix`: `fd`, `ripgrep`, `bat`, `eza`, `zoxide`, `atuin`, `carapace`, `direnv`, `gum`, `wget`, `websocat`
- `files.nix`: `yazi`, `ouch`, `p7zip`
- `search.nix`: `television`, `tealdeer`, `nix-search-cli`, `nix-search-tv`
- `watch.nix`: `viddy`, `progress`, possibly `procs`

## Proposed `ops` Layout

```text
modules/home/ops/
  default.nix
  monitor.nix
  secrets.nix
  sync.nix
```

- `monitor.nix`: operational observability tools such as `lazyjournal`
- `secrets.nix`: `sops`, `age`, `ssh-to-age`, and possibly `bitwarden-cli`
- `sync.nix`: `syncthing`

## Implementation Steps

1.  Split `cli/modern-unix.nix` into focused modules.
2.  Move `ops/file-io.nix` to `cli/files.nix`.
3.  Move `ops/search.nix` to `cli/search.nix`.
4.  Decide whether `procs`, `progress`, and `viddy` belong in `cli/watch.nix` or remain in `cli/essentials.nix`.
5.  Rename `ops/sops.nix` to `ops/secrets.nix` and fold `ops/security.nix` into it if appropriate.
6.  Rename `ops/syncthing.nix` to `ops/sync.nix`.

## Success Criteria

- `cli` owns reusable terminal ergonomics.
- `ops` owns admin-oriented services and operational tools.
- No package is duplicated between the two domains.
- Existing commands and Home Manager options remain available after switch.
