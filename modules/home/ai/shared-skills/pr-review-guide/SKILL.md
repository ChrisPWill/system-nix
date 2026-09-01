---
name: pr-review-guide
description: Produce a review guide for someone else's PR — a reading order, a map of the correctness argument, and findings triaged by whether they should block. Use when asked for a review guide or review plan, or how to review a given PR.
argument-hint: <pr-url-or-number>
---

# PR Review Guide

Produce a guide that makes a human a faster, sharper reviewer of someone else's PR. The output
is **not** a review — you are not approving, requesting changes, or leaving comments. You are
handing the reviewer a reading order, the assumptions the change rests on, and a triaged findings
list so they know where to spend their comments and where not to.

## The distinction that makes this useful

A code review says "here is what is wrong". A review guide says "here is what to check, here is
why it matters, and here is the question to ask". Every finding ends in a question the reviewer
can paste into a comment thread — because the author knows things you do not, and a question
survives being wrong in a way an assertion does not.

The most valuable section is often the one that tells them **what not to comment on**. Reviewers
waste credibility flagging interface-imposed idioms, legacy wiring that the PR correctly leaves
alone, or a documented deviation from a rule. Clearing those away is real work.

## When Not to Use

- **The user wants the review itself, not a guide to doing one** — findings to act on, inline
  comments posted, or fixes applied. That is `code-review`, which takes the same PR-number and
  branch targets and can post or apply what it finds. This skill assumes a human will do the
  reviewing and needs to be equipped for it.
- **Security-specific audit** — use `security-review`.
- **The PR is the user's own work** and they want it cleaned up before review — that is
  `ai-slop-cleaner` or `pr-description-improver`.
- **Mechanical PRs** — dependency bumps, generated files, pure renames. Say the diff is mechanical,
  name the one thing worth eyeballing, and stop. A guide is overhead there.

## Target

The PR is `$1`. It may be a number or a full URL; `gh` accepts either and infers the repo from a
URL, so a PR in another repository works without changing directory.

If `$1` is empty — which happens when this skill is invoked by description match rather than typed
as a command — resolve the target from the conversation or the current branch
(`gh pr status --json number,url`). If that is ambiguous, ask. Do not guess at a PR number.

## Scope and setup

Reading a diff needs no isolation, so **do not create a worktree and do not ask about one**. This
deliberately overrides the global source-control rule about asking between `jj` and a worktree —
that rule is about modifying code, and this skill modifies nothing. Create a worktree only if you
need to build or run the branch to settle a specific question, and say why when you do.

## Gather

Prefer reading over fetching.

```sh
gh pr view $1 --json title,body,author,baseRefName,headRefName,additions,deletions,changedFiles,commits
gh pr view $1 --json comments,reviews,statusCheckRollup
gh pr diff $1 --name-only
gh pr diff $1 > <scratchpad>/pr.diff
```

Read the existing review state before forming findings. A point another reviewer already raised is
worse than no point at all, and failing CI reframes the whole guide — if the build is red, the
first thing the reviewer needs is whether the failure is real.

Read the PR description properly. A well-written one states the author's own correctness argument —
that argument is the thing you are auditing. A thin one means you derive the argument yourself and
should say so.

Then **cross-check the diff against the code already in the working tree**. This is where the
findings come from, and it is what separates a guide from a summary of the description:

- Find the sibling the change is modelled on — the existing scheduled job, handler, or migration of
  the same kind — and diff the reasoning, not just the shape.
- Trace each value the change trusts to its definition. If the PR claims two paths agree on an
  amount, open both and confirm it.
- Read the contract or interface the change depends on. Check whether the guarantee the PR leans on
  is actually asserted anywhere, or only stated in prose.
- Check the repo's own conventions — `CLAUDE.md`, `AGENTS.md`, a `.claude/rules/` directory,
  `CONTRIBUTING.md`, whichever exist — so a deviation reads as deliberate-and-justified or as an
  oversight.
- Look for what the diff makes newly reachable: a scheduled scan with no index, a list with no
  bound, a log line interpolating an unbounded collection.

**Classify the changed files before judging the diff's size.** Production, test, and
generated-or-config are three different things, and a raw line count flatters or damns a PR
wrongly. Derive the split from the repo's actual layout rather than assuming one — look at where
its tests live and how they are named (a `test`/`tests`/`spec` directory, a `__tests__` folder, a
`_test`/`.spec`/`.test` filename suffix) and treat lockfiles, snapshots, generated clients, and
build config as neither production nor test. Report the split; do not just report the total.

## Find the assumptions the change rests on

Most PRs rest on one or two claims that, if false, make the change wrong in a way tests do not
catch. Name them explicitly. The recurring shapes:

- **A guarantee owned by someone else.** "The downstream service dedupes by key." Check whether any
  test in this repo fails if it does not.
- **A guarantee that is true today for an incidental reason.** Two independent filters that happen
  to agree, or a cadence that happens to exceed a window.
- **A no-op that switches on later.** A change that ships inert and becomes live when another team
  lands their half. The review moment and the risk moment are far apart — say so, because it changes
  what the reviewer should insist on now.
- **Two windows that should match and do not.** A sweep over N days fed by a query scoped to one.
  This is a reliable source of real findings; check every pair of ranges against each other.

## The correctness table

The centrepiece of the guide. One row per claim the change depends on:

| Claim | What it rests on | Test that pins it |
|---|---|---|

A row whose final cell reads `nothing` is your strongest finding, and the table makes it undeniable
rather than asserted. Build this before writing the findings list — the empty cells generate most
of the findings, and the filled ones tell you what not to raise.

## Structure

Build to this skeleton. Drop a section rather than pad it, but do not reorder — it runs from
orientation to judgement.

1. **What you are actually being asked to approve.** State the behaviour, then the one fact that
   reframes the review (it is inert on merge; it is behind a flag; it changes money). Keep it to a
   short paragraph plus that callout — the reviewer has not seen any code yet, so length here is
   spent before it can be used.
2. **The order to read it in.** A numbered path — legitimately a sequence, so numbering earns its
   place. Point at files, name what to check in each, and say why that file is where the interesting
   reasoning lives. If the commits are well-formed, tell them to read commit-by-commit and say so.
3. **The correctness argument, and where to attack it.** The table above.
4. **Findings to raise.** Triaged, ordered by what you would hold the PR on:
   - *block* — ask before approving
   - *probe* — ask, accept a good answer
   - *nit* — optional, grouped into a single entry
   - *checked* — you verified it against the tree and it holds; do not re-litigate
   - *out of scope* — interface-imposed idiom, or legacy the PR correctly leaves alone

   Each substantive finding: what it is, the mechanism, then an italicised **Ask:** line the
   reviewer can paste.
5. **Test review checklist.** Checkboxes for spot-checking, not a summary of every test. Include the
   gaps as unchecked items so the absence is visible next to the coverage.
6. **Verify locally.** The commands, plus explicitly: which claim in the description is the one they
   cannot check from the diff and should confirm themselves.
7. **How I'd land the review.** Say what is genuinely good, then name the specific findings you would
   hold on and which are threads that should not block. A guide that will not commit to a verdict
   makes the reviewer do the work twice.

## Calibration

- **Be fair about quality.** If the work is careful, say so concretely — layered commits, tests that
  fail for the right reasons, a self-correcting pass that caught a real bug. Praise that names
  specifics is information; praise that does not is noise.
- **Findings must have a mechanism.** "This might not scale" is not a finding. "This reads every
  matching row for every account with no limit, and the table declares no index covering the
  predicate" is.
- **Do not invent blockers.** Two real blocking findings beat six speculative ones. If nothing should
  block, say the PR should be approved and spend the guide on the threads worth opening.
- **Verify before you flag.** If you can check a claim against the tree in one grep, check it. A
  guide that sends the reviewer to argue about something the code already handles costs them
  credibility with the author.
- **Never speculate about the author.** Findings are about the change.
- **Write it short.** Short paragraphs, one to three sentences. The guide is read next to the diff,
  not instead of it — every line that restates what the reviewer is about to see costs attention
  they need for the findings.
- **Say what you did not read.** If the diff is larger than you can work through carefully, cover
  the highest-risk subset and name the files you skipped and why. Silent partial coverage is the
  one failure that makes the whole guide untrustworthy.

## Deliver

For a small PR, deliver in chat. The guide is short enough to read in place, and an artifact is more
ceremony than the review.

For anything larger — where the reviewer will work through it next to the PR, come back to it, or
share it in the thread — load `artifact-design` and publish as an HTML artifact. Utilitarian
treatment: real hierarchy, severity chips, a scannable findings list; no hero.

Artifacts render Mermaid natively, so include a diagram where the change has shape worth showing:
the flow before and after, the sequence across services, the state machine a new status field
introduces. Prefer separate top-level diagrams over subgraphs, so the reading order is the one you
intended, and give each a heading saying what it shows. Skip the diagram when the change is small or
linear — a diagram of something trivial reads as padding. Load `artifact-diagramming` if the diagram
needs to be inline SVG rather than Mermaid.

Either way, state the one or two findings you would hold on directly in chat, in full — the reviewer
often acts on those before opening the guide.
