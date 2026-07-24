# Development Environments

Language runtimes and tooling are provided by named Nix devshells, not by the
base Home Manager or editor closures. Neovim and Helix keep their integrations
configured, then activate LSP, formatting, linting, testing, and debugging only
when the required executable is on `PATH`.

Launch the editor from the activated environment. An editor launched before
activation cannot see a later shell's tools.

## Shell catalog

| Shell                   | Tooling                                                          |
| :---------------------- | :--------------------------------------------------------------- |
| `nix`                   | nixd, Alejandra, statix, deadnix                                 |
| `shell`                 | Bash/Fish LSPs, shellcheck, shfmt, TOML/YAML/JSON/Markdown tools |
| `lua`                   | Lua, lua-language-server, stylua                                 |
| `python`                | Python 3.14, basedpyright, ruff, debugpy, pytest                 |
| `rust`                  | Rust, rust-analyzer, rustfmt, clippy, LLDB                       |
| `go`                    | Go, gopls, go-tools, delve, golangci-lint                        |
| `cpp`                   | LLVM/C++, clang-tools, GDB, LLDB, CMake, Ninja, Make             |
| `jvm`                   | JDK 21, Kotlin LSP, JDTLS, google-java-format                    |
| `node22` / `node24`     | Node, Yarn, TypeScript/web LSPs, formatters, linters, debugger   |
| `system-nix`            | Composite `nix`, `shell`, and `lua` environment                  |
| `sequence-platform-api` | `jvm`, `python`, and API/cloud dependencies                      |
| `sequence-web`          | `node22` and certificate dependencies                            |

Run `nd` to list the shells available on the current system. Enter one with
`nd rust`, or without the helper:

```bash
nix develop ~/.system-nix#rust
```

## Persistent directory mappings

Envoluntary loads configured shells as the working directory changes. The
tracked configuration ships mappings for `.system-nix`, `sequence-platform-api`,
and `sequence-web`. Add an explicit project mapping with:

```bash
envoluntary config add-entry '~/code/project(/.*)?' '~/.system-nix#rust'
```

Broad marker matching is deliberately opt-in. These examples walk upward from
the current directory and activate only when the adjacent marker exists:

```bash
envoluntary config add-entry '.*' '~/.system-nix#rust' --pattern-adjacent '.*/Cargo\.toml'
envoluntary config add-entry '.*' '~/.system-nix#go' --pattern-adjacent '.*/go\.mod'
envoluntary config add-entry '.*' '~/.system-nix#python' --pattern-adjacent '.*/pyproject\.toml'
envoluntary config add-entry '.*' '~/.system-nix#node22' --pattern-adjacent '.*/package\.json'
envoluntary config add-entry '.*' '~/.system-nix#cpp' --pattern-adjacent '.*/CMakeLists\.txt'
envoluntary config add-entry '.*' '~/.system-nix#jvm' --pattern-adjacent '.*/(settings|build)\.gradle(\.kts)?'
```

Because the active config is an out-of-store symlink, `config add-entry`
updates the tracked
`modules/home/dev/envoluntary/envoluntary.toml` file.

## Diagnostics and cache refresh

Show the entries matching a path:

```bash
envoluntary config print-matching-entries "$PWD"
```

Show a shell's cache location and force a profile refresh:

```bash
envoluntary shell print-cache-path '~/.system-nix#rust'
envoluntary shell export zsh --flake-references '~/.system-nix#rust' --force-update >/dev/null
```

Use `bash`, `fish`, or `zsh` as appropriate for `shell export`. Cached profiles
can retain store paths after a shell stops being active; normal Nix root/cache
cleanup makes those stacks collectible.

Mise remains installed for `mise run` and other explicit project commands. Its
automatic shell hooks and global Node default are disabled, so Nix is the
authoritative runtime provider.
