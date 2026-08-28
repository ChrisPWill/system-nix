---
name: pr-description-improver
description: Write or tighten a pull request description so it carries only what the diff cannot. Use when drafting a PR body, improving an existing description, or preparing to raise a PR.
---

# PR Description Improver

The diff already shows what changed. The description exists for what a reviewer
cannot read off the diff: why the change was made, which alternatives were
rejected, where the risk sits, and how to review it efficiently.

## When to Use

- drafting the body for a new PR
- asked to tighten, shorten, or improve an existing PR description
- a description has drifted out of date after review feedback

## When Not to Use

- writing commit messages — use `git-commit`
- writing a tech proposal or user story — those are upstream artifacts
- the PR is a pure mechanical change (dependency bump, generated file, rename);
  a one-line title and body is the correct output

## Ticket Link (required)

Every PR references its ticket in both places:

- **Title** — the ticket key, following the repo's existing convention. Check
  recent merged titles (`gh pr list --state merged --limit 10`) rather than
  assuming a format.
- **Description** — a link to the ticket, either in the opening line or under
  `## Related`.

If no ticket exists, stop and ask. Do not raise a PR against an invented key and
do not quietly omit it — an unticketed change is either a tracking gap or a sign
the work belongs to existing scope.

## Core Rules

1. **Cut what the diff says.** Do not restate file-by-file changes, function
   names, or the shape of the code. Explain an implementation detail only when a
   reviewer would otherwise misread it — a non-obvious ordering constraint, a
   deliberate deviation from the surrounding pattern, a workaround for an
   upstream bug.
2. **Lead with why.** The first paragraph states the problem and the decision.
   If the ticket already states the problem, link it and go straight to the
   decision.
3. **One claim per line.** No throat-clearing, no "this PR does X" preamble, no
   restating the title.
4. **Never tag people.** No `@handles`, no "cc" lines, no named reviewers.
   Routing belongs in the reviewer field or a chat message, not in a permanent
   record. Refer to roles or teams if context genuinely requires it.
5. **Related work is a pointer, not a story.** Prior work and follow-up work get
   one line each, maximum. Let PR and ticket numbers do the work:
   `Follows #412. Deletes the legacy path in ENG-1180.` If a follow-up needs a
   paragraph, it needs its own ticket.
6. **Flag risk, briefly.** Migrations, feature flags, config or infra changes,
   and anything not covered by tests get named — silence reads as "no risk".
   One line each is the default: the thing, and its blast radius. Spend more
   than a line only when a risk is both likely to bite and hard to undo; then
   add how it would show up and what the rollback is. Anything unlikely or
   trivially reversible gets a clause, not a paragraph. If the risk section is
   longer than the "what changed" section, it is overwritten.

## Voice

Write like a colleague explaining the change at their desk, not like a release
note.

- Short paragraphs, one to three sentences. Break anything longer, but do not
  shred everything into bullets either — some claims need a sentence around them.
- Plain declarative sentences, of varying length. Uniform rhythm reads as
  generated.
- Say the specific thing. "Retries were amplifying the burst" beats "there were
  performance implications".
- Contractions are fine. Hedging is not — if a claim needs "arguably" or
  "generally", verify it or cut it.
- Avoid the stock LLM register: "load bearing", "delve", "leverage",
  "seamlessly", "robust", "comprehensive", "it's worth noting", "at its core".
  Never "this isn't just X, it's Y".
- No emoji, no bolded lead-in on every bullet, no three-item lists where two
  items say it.
- The first sentence carries information. Do not open with a summary of the
  summary.

## Tables and Diagrams

Welcome where the change has structure worth showing. Not a default, and not
something to avoid — judge it per PR.

Reach for one when:

- **Table** — three or more items compared across consistent attributes:
  endpoints and their new status codes, config keys and their defaults,
  behavior per case before and after.
- **Mermaid** — ordering, control flow, state transitions, or hops between
  services carry the meaning.

Leave them out when the change is small or linear: a bug fix, a rename, a config
tweak, a two-step flow. A sentence is shorter and reads faster there, and a
diagram of something trivial reads as padding.

When you do include one:

- **Prefer separate diagrams over subgraphs.** Mermaid gives no ordering
  guarantee for subgraph layout, so a reader's eye path is not the one intended.
  Two top-level diagrams under their own headings preserve the sequence:

````
### Before
```mermaid
...
```

### After
```mermaid
...
```
````

  Reach for a subgraph only when the grouping is itself the point — nodes that
  share a boundary, a process, or a trust zone.
- Every diagram needs a heading or lead-in saying what it shows. An unlabelled
  diagram is a puzzle.

## Default Structure

Drop any heading that would be empty. Most PRs need only the first two.

```markdown
<Why this change, and the decision made. 1-3 sentences.>

## What changed
<Bullets at the level of behavior, not code. 2-5 lines.>

## Review notes
<Where to start, what to look at hardest, anything non-obvious.>

## Risk
<One line per risk. Expand only for the likely-and-hard-to-undo ones.>

## Related
<One line for prior work. One line for follow-up work.>
```

## Workflow

1. **Read the actual diff** — `gh pr diff` or `git diff <base>...HEAD`. Never
   write a description from the branch name, the ticket, or the commit log
   alone.
2. **Extract what is not visible in the diff**: the reason, the rejected
   alternatives, the risk, the review path.
3. **Draft against the structure above.**
4. **Run a cut pass.** Delete every line a reviewer would learn from the diff
   itself. Delete every sentence that survives as a fragment.
5. **Check the rules**: ticket in title and description, no tags, related work
   within its line budget, risk kept to a line each unless a risk is genuinely
   likely and hard to undo, every table and diagram earning its space, nothing
   from the banned register.
6. **Ask, do not invent.** If the why or the rollout plan is not recoverable
   from the diff, commits, or linked ticket, ask rather than guessing — a
   plausible fabricated rationale is worse than an open question.

## Example

**Before** — title `Add rate limiter`

```markdown
This PR adds a new `RateLimiter` class in `src/http/rate_limiter.ts` which
implements a token bucket algorithm. It exposes `acquire()` and `release()`
methods. We also modified `ApiClient` in `src/http/client.ts` to call
`acquire()` before each request. Additionally the `RETRY_LIMIT` constant was
moved from `constants.ts` to `config.ts` for better organization.

This builds on the work in #388 where we added retry handling, which itself
followed #372's client refactor. In future we plan to make the bucket size
configurable per-tenant, and eventually to share limiter state across pods via
Redis so that limits hold cluster-wide rather than per-instance.

cc @sarah @mike for review
```

**After** — title `ENG-1187: Rate-limit vendor API calls client-side`

```markdown
The vendor API started returning 429s under normal load, and our retry logic
made it worse by amplifying bursts. Adds client-side token-bucket limiting so we
shape traffic before it leaves the process. [ENG-1187](https://linear.app/…)

Bucket size is hardcoded to the vendor's documented ceiling — per-tenant tuning
needs usage data we do not have yet.

## Risk
Limiter state is per-pod, so the effective cluster limit scales with replica
count — acceptable at current fleet size (ENG-1204).

## Related
Builds on #388 (retry handling). Follow-up: ENG-1204.
```
