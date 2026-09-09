---
name: refine-ticket
description: Review and tighten existing tickets so they state a clear action, read correctly to non-technical colleagues, and don't assert anything unverified. Use when asked to review, refine, tidy, or improve tickets — or after drafting a batch, before anyone else reads them.
argument-hint: <ticket-key-or-url>
---

# Refine a ticket

A ticket is read by people who weren't in the conversation that produced it: the product
lead sizing a milestone, a support engineer wondering if it explains a customer's problem,
whoever picks it up in three weeks. Refinement means making it survive that audience.

## When to Use

- asked to review, refine, tidy, or improve one or more existing tickets
- a batch of tickets has just been drafted and hasn't been read by anyone else yet
- a ticket's scope changed and the rest of it hasn't caught up
- a ticket is about to be picked up and nobody is sure what "done" means

## When Not to Use

- creating a ticket from scratch — use the ticket-creation skill, then come back to this
  before handing the batch over
- writing a PR description — use `pr-description-improver`
- the ask is to *do* the work the ticket describes; refinement is not implementation

## Refinement can subtract

A ticket that already passes every test below is finished. Say so and change nothing —
a refinement pass that always produces edits is producing noise. Equally, shortening is a
valid outcome: cut restated context, collapse three paragraphs into one, delete a section
that says nothing. The structure described later is a ceiling, not a target. A clear
four-line ticket does not need collapsibles.

## The seven tests

Apply each to every ticket.

### 1. The title states an outcome, not a mechanism

If the title names a class, a field, or a code change, it's written for the author.
Rewrite it as what becomes true when the ticket is done.

- `Add a scope discriminator (SCHEDULE / CUSTOMER)` → `Let a credit grant belong to a
  customer rather than a billing schedule`
- `Remove the credit consumption lock` → `Remove the lock that makes customers wait up to
  30 minutes for credit to apply`

The second pair is the better move: where there's a user-visible cost, put it in the title.

### 2. Every actor is named

Hunt for passive or unowned phrases — "this makes it findable", "everything else builds on
this", "the dashboard needs it". Ask *what* or *who*, specifically, and list them.

This is not cosmetic. Naming consumers often reveals that some are certain and some are
contingent on an open decision, which sharpens both the justification and the scope
boundary. If you can't name a single concrete consumer, question whether the ticket should
exist yet.

### 3. Acceptance criteria are checkable by someone else

Each "done when" line must be verifiable without reading the author's mind:

- Not `the type is correct` → `a customer grant cannot be created with a schedule`
- Not `nothing else breaks` → `the existing acceptance tests pass unchanged, and drawdown
  for schedule-level grants behaves as it does today`

Regression claims especially need a named way to check them.

### 4. The ticket doesn't promise what it doesn't build

Read the criteria as a stranger. If one implies a capability the scope explicitly defers,
you have a real defect — someone will either build the deferred thing or tick a box that
isn't true. Either bring it into scope or reword it.

Watch for this after any scope change: criteria written before a decision often outlive it.

### 5. Deferrals are interrogated, not inherited

For anything marked blocked or deferred, ask *precisely* what it's waiting on. Bundled
deferrals are common: one part genuinely blocked, another part free, deferred together out
of caution.

Split them. Say what would unblock the remainder, by name — a decision, a person, a
prerequisite ticket. "Waiting on designs" is not a blocker unless you can say which
decision in those designs changes the work.

### 6. Provenance is explicit, and staleness is flagged

For every figure, quote, and claim, know where it came from and whether it was verified
*now* or inherited from an earlier write-up.

Inherited numbers are fine. Inherited numbers presented as current are not. Say where they
came from and give an absolute date — "as of 27 Aug", never "recently" or "last week",
because the ticket outlives the conversation. State plainly that they haven't been
re-checked: production estates move, and a ticket quoting a stale count will be trusted
anyway.

Verify rather than inherit where a tool can settle it — search the codebase for an
identifier, query the database for a count, open the linked PR or document. Doing so
routinely turns up something better than a tidier ticket.

### 7. The ticket doesn't contradict itself

Read it top to bottom in one pass. A lead paragraph asserting something a later section
denies is easy to introduce when facts arrive out of order, and it destroys trust in
everything else on the page.

## Never invent

If something is unclear, **stop and ask**. Do not paper over a gap with plausible
language — a confident sentence in a ticket becomes a decision someone else acts on.

Specifically, never:

- invent a file path, endpoint, flag name, table, or identifier — search for it, and if you
  can't find it say so in the ticket
- restate a figure without knowing its source
- assert a decision was made because it seems to follow from what was
- convert someone's proposal into settled fact, or a hedge into a certainty
- guess at intent behind a status change, cancellation, or edit someone else made

When a source hedges, hedge with it, and attribute: "Killian, 27 Aug", "proposed, not
ratified", "assumed unless told otherwise".

## When to ask rather than decide

Ask when the answer changes the work rather than its wording. Use one round of questions
covering everything open, not a drip of separate ones.

**Always ask before:**

- changing status, assignee, priority, milestone, or team — these belong to the user and
  their sprint process
- closing, cancelling, merging, or splitting a ticket
- reversing a decision recorded in a ticket
- retitling, if the ticket has been shared, referenced, or has a branch in flight

**Ask when:**

- two readings of the scope would produce materially different work
- a claim can't be traced and matters to the conclusion
- the right home is ambiguous — which milestone, which team, whether it's one ticket or two
- refinement uncovers a defect beyond the ticket's stated scope: report it, don't quietly
  widen the ticket

**Decide yourself, and say what you decided:**

- wording, structure, ordering, collapsing long context
- correcting a figure you can prove is wrong
- adding a criterion that was clearly implied
- fixing an internal contradiction

Report every judgement call in the summary, so it can be overridden cheaply.

## Tooling

Read the stored ticket before judging it and again before writing to it — never refine from
what you remember drafting. Use the tracker's own read/write tools (in Linear, `get_issue`
and `save_issue`) rather than a browser fetch, so you see the raw markdown you're about to
patch.

For test 6, prefer the tool that settles the question over the plausible answer:

- identifiers, paths, flags, table and column names — search the codebase
- counts and estate statistics — query the database directly, and record the date
- "we decided X" — find the comment, document, or PR that says so, and link it

If no tool can settle it, say so in the ticket rather than smoothing it over.

## Structure

Lead with two or three plain sentences: what changes, and why anyone cares. No jargon in
the first paragraph.

Then a visible `## Done when` checklist — the action must be readable without expanding
anything.

Then, if scope is contested, `## Not in scope` with the reason for each exclusion.

Everything else goes in a collapsible: code names and types, evidence tables, estate
statistics, cross-team nuance, provenance, historical background.

## Linear specifics

Collapsible sections are delimited by a line of three `>` characters — one opening the
section with its title, one on its own closing it. **They must be paired.** An unclosed
section is parsed as a nested blockquote and renders as mangled indented text.

Linear rewrites some markdown on save — ticket references become link elements, for one —
so a targeted patch may fail to match text you wrote moments earlier. Re-read the stored
description before patching, or replace it wholesale.

## Batches

When refining more than one ticket, the set has defects the individual tickets don't:

- **Overlapping scope.** Two tickets that would have the same person editing the same code
  are one ticket or a badly drawn boundary. Report it; don't merge them unasked.
- **Inconsistent terminology.** The same concept named three ways across a batch reads as
  three concepts. Pick the one the domain already uses and say which you standardised on.
- **Dependency order.** If B can't start until A lands, say so in B, naming A. Check the
  batch is orderable at all — a cycle means the split is wrong.
- **Duplicated context.** The same background pasted into six tickets goes stale six ways.
  Put it in the parent project or one ticket and link to it.
- **One round of questions for the whole batch**, not one per ticket.

Read every ticket in the batch before editing any of them.

## Voice

Write for the colleague who wasn't there, not for a release note.

- Short paragraphs, plain declarative sentences of varying length. Uniform rhythm reads as
  generated.
- Say the specific thing. "Credit applies up to 30 minutes late" beats "there are
  performance implications".
- No hedging as decoration — if a claim needs "arguably" or "generally", verify it or cut
  it. Hedge only where the source hedged, and attribute it.
- Avoid the stock LLM register: "delve", "leverage", "seamlessly", "robust",
  "comprehensive", "it's worth noting", "at its core".

## Finishing

Report, per ticket: what changed, what you decided and why, and anything you found but
didn't act on. Say plainly when a ticket needed nothing. Call out separately:

- factual errors corrected
- claims that remain unverified
- defects the review exposed that need a decision
- anything another person changed while you were working, without reverting it

If the tickets are mirrored anywhere — a planning doc, a scoping ticket, a project page —
say that it now needs updating. Don't update it unasked.

## Cross-team tickets

Name the other team's dependency explicitly, and say whether it's a genuine handoff or
something the owning team could absorb. Default to describing the shape of the dependency
and who to ask, rather than asserting a handoff that hasn't been agreed.

Never raise or edit a ticket in another team's area on their behalf without being asked.
