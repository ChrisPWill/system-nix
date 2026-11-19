# PR review (`nvr`)

A separate Neovim build, `review`, for reviewing GitHub PRs with
[Octo](https://github.com/pwntester/octo.nvim). It has the same LSPs and
formatters as `meow` but no AI integrations, so a review session starts
without them. Defined in `nixcats-package.nix`; commands live in
`config/lua/review.lua`.

## Start

| Shell            | Opens                                                         |
| ---------------- | ------------------------------------------------------------- |
| `nvr`            | PRs waiting on your review                                    |
| `nvr 123`        | PR 123 of the repo in the current directory                   |
| `nvr <PR URL>`   | That PR. The current directory must be a clone of its repo.   |

Octo reads file contents with `git show`, so `:PR` and `:PRReview` first run
`git fetch origin pull/N/head`. Your working copy is not touched.

## Commands

| Command            | Key          | Does                                                    |
| ------------------ | ------------ | ------------------------------------------------------- |
| `:PR [n or URL]`   |              | Open a PR (no argument: PR list)                        |
| `:PRInbox`         | `<leader>Ri` | PRs requesting your review                              |
| `:PRMine`          | `<leader>Rm` | Your open PRs                                           |
| `:PRReview`        | `<leader>Rr` | Start or resume a review                                |
| `:PRApprove`       | `<leader>Ra` | Write a body, `<CR>` to submit as approval              |
| `:PRRequestChanges`| `<leader>Rx` | Write a body, `<CR>` to submit requesting changes       |
| `:PRChecks`        | `<leader>Rc` | CI check status                                         |
| `:PRLogs`          | `<leader>Rl` | Log of the first failing CI job                         |
| `:PRCheckout`      | `<leader>Rw` | jj workspace (or git worktree) at `../<repo>-pr-N`      |
| `:PRUrl`           | `<leader>Ru` | Copy the PR URL                                         |
| `:PRGuide`         | `<leader>Rg` | Run the `pr-review-guide` skill in a terminal split     |

## In a review

- `]q` / `[q`: next / previous file. `]h` / `[h`: next / previous change.
- `]t` / `[t`: next / previous comment thread.
- `<localleader>ca`: comment. `<localleader>sa`: suggestion.
- `<localleader><space>`: mark the file as viewed.
