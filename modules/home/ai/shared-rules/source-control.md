# Source Control

- Prefer Jujutsu (`jj`) for source-control operations when it is available and
  the repository supports it.
- Use Git when working in a Claude worktree or similar that won't smoothly work with `jj`
- Try the equivalent `jj` command before falling back to Git.
- Use Git when `jj` cannot perform the required operation or the repository's
  documented workflow explicitly requires Git.
- Keep each task in its own Jujutsu change. Before starting unrelated work,
  run `jj new` so existing in-progress work remains preserved in its own
  change.
- After describing, committing, or pushing a change, run `jj new` before
  continuing with further work. This avoids accidentally editing a previously
  committed or pushed change.
