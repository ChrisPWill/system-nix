---
name: change-walkthrough
description: Walk a reviewer through every behaviour change and refactor in a PR, branch or revision range, with labelled fields, before/after diffs, the test that proves each one and a "who notices" table. Use when asked to summarise each change or refactor with code snippets, to walk through a diff, to explain what a branch changed in production, or to prepare someone to review a PR.
---

# Change walkthrough

Write a walkthrough that a reviewer reads once, top to bottom, and then knows:
what behaves differently, what data ends up different, how each claim is
proven, and who outside the code will notice.

Write the walkthrough in chat. Never post it to GitHub, Slack, a ticket or anywhere
else unless asked.

## Arguments

- **Target**: a PR number or URL, a branch, or a revision range. With no target, use
  the current branch against `origin/main`. If it's still unclear, ask rather than
  guess.

## Gather the facts

Read the change itself. Commit messages and PR descriptions are claims, not
evidence.

1. `git log --format='%h %s%n%n%b----' origin/main..HEAD` (or `gh pr view <n>`):
   the stated intent and ticket.
2. `git diff --stat origin/main...HEAD`: what moved.
3. `git diff origin/main...HEAD -- '*/src/main/*'`: production code, read in full.
4. `git diff origin/main...HEAD -- '*/src/test/*' | grep -E '^\+\s+fun |^diff --git'`:
   new test names, used for the **Proof** lines.
5. `grep -n` the current file for each symbol you will cite, so every `file:line`
   points at HEAD rather than at a diff hunk offset.

Look at the end result, not commit by commit. If a later commit undoes or reshapes
an earlier one (for example a `Pair` replaced by a named type), describe only the
final state.

## Classify every change

Put every production change in exactly one of these groups:

- **Behaviour change**: a caller, customer, operator, job or dashboard can see a
  difference. This includes anything that changes what gets written to the
  database (a status, a row, which job picks something up), even if the change is
  "internal".
- **Refactor**: the same inputs give the same outputs. If you can't argue that in
  one sentence, it's a behaviour change.

Removed code goes in a group too: deleted branches, classes and tests.

## Structure

Use this order. Title the walkthrough with the ticket and a plain-language
consequence: `# PULSE-123: corrections no longer get stuck behind earlier corrections`.

### 1. Opener: a picture of the change

Pick one:

- **Status table**: when the change is mainly about which status or path a record
  ends up in. One row per case, including the cases that did not change, so
  the reader sees where the boundary is.

  | Case | Before | Now | What picks it up next |
  |---|---|---|---|

- **Flow diagram** (the default otherwise): a mermaid `flowchart` of the path a
  request, job or record takes, with the new or changed edges labelled. Keep each
  label on one line: no `<br/>`; use " - " to join phrases.

Add a **worked example** under the opener only when a test or fixture gives real
numbers to quote (dates, amounts, ids). Take them from the test; never invent them.

### 2. Behaviour changes

Number them, starting at 1, most important first. Each one uses exactly these
labels:

```
### N. <one-line claim in plain language>
- **Before:** what happened, as someone would observe it
- **Now:** what happens instead
- **Why:** the reason, as a consequence for a person or a job
- **Notice:** who or what sees the difference, or "none"
- **Proof:** `TestClass` › *test name*, the test that would fail with
- **Where:** `repo/relative/path/File.kt:123`

```diff
- old line
+ new line
```
```

Rules for the diff:

- Before → after, trimmed to the lines that carry the decision: 3–12 lines.
  Keep one or two context lines only if they're needed to make sense
- If the change is a new file or a new function, show only the core of the new
  code in a ```kotlin``` block (or whatever the language is), plus th
  code if it replaced something.
- Never paste a whole file. If one diff can't show the logic, add a s
  block with a one-line comment above it.

### 3. Refactors (no behaviour change)

Continue the numbering. Use the shorter label set:

```
### N. <one-line claim>
- **Before:** …
- **Now:** …
- **Proof:** test name, or "covered by existing tests"
- **Where:** `path:line`
