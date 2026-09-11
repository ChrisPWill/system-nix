---
name: refine-ticket
description: Review and tighten existing tickets so they state a clear action, read correctly to non-technical colleagues, and don't assert anything unverified. Use when asked to review, refine, tidy, or improve tickets — or after drafting a batch, before anyone else reads them.
argument-hint: <ticket-key-or-url>
---

# Refine a ticket

A ticket is read by people who weren't in the conversation that produced it: the product
lead sizing a milestone, a support engineer wondering if it explains a customer's problem,
whoever picks it up in three weeks. Refinement means making it survive that audience.

Most of the work is selection, not phrasing. A ticket can be accurate, well-worded and
shorter than it was, and still fail because the reader can't find the recommendation, or
can't tell which of eleven sentences is the thing to do. Decide what belongs before you
decide how to word it.

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

Deleting beats hiding. Moving a redundant paragraph into a collapsible leaves it in the
ticket, where it will be read, quoted, and go stale. If it doesn't help someone do the
work or judge it, remove it.

## First, identify the ticket type

Do this before any other test. "Done" means something different for each type, and getting
it wrong is what turns a small decision into a research project, or makes a parent ticket
restate every child's criteria.

| Type | What "done" means |
| --- | --- |
| **Implementation** | Behaviour changed, and the change was validated. |
| **Investigation** | A stated question is answered with evidence, and a recommendation is recorded. |
| **Decision** | A choice is recorded, with the person who owns it. Implementation criteria only if implementation is already in scope. |
| **Parent** | The child outcomes landed, plus any validation that is only possible once they are combined. |

If a ticket is two types at once — "work out whether we should, then do it" — say which
part this ticket completes. Usually it should be split, but report that rather than
splitting it unasked.

Type mismatches to watch for:

- a decision ticket carrying implementation acceptance criteria for an approach nobody has
  chosen yet
- an investigation whose criteria describe code changes rather than an answer
- a parent repeating each child's criteria, so closing it requires re-verifying work that
  was already verified

## The tests

Apply each to every ticket.

### 1. A reader can decide quickly

From the visible opening and the checklist alone — expanding nothing — a reader should
come away with four things:

1. the problem
2. the proposed action
3. the unresolved decision, if there is one
4. the condition for being done

If the recommendation is inside a collapsible, the ticket fails, however tidy the
collapsible is. The same is true when a secondary open question sits in the opening while
the actual recommendation is buried below it: prominence has to match importance.

This is the first test because it is the one that survives cleanup passes. Shorter
checklists and more collapsibles do not, on their own, make a ticket decidable.

### 2. The checklist is short, outcome-based, and matches the type

Aim for **three to five** criteria. Use more only when a distinct requirement would
otherwise disappear — never to keep a narrative intact.

- Each line is an outcome someone else can check, not an instruction to the implementer.
- Do not compress ten requirements into four dense sentences. Four unreadable lines are
  worse than seven readable ones — and usually mean the ticket is too big, or that most of
  those requirements are implementation detail.
- Not `the type is correct` → `a customer grant cannot be created with a schedule`
- Not `nothing else breaks` → `the existing acceptance tests pass unchanged, and drawdown
  for schedule-level grants behaves as it does today`

Regression claims especially need a named way to check them.

**Separate the completion criterion from the procedure.** "Run the load-testing repo
before and after the change, and record both results" is a criterion. The command, the
config, the dataset and the thresholds belong under a `## How to load test` heading below
the checklist.

Everything else moves below the checklist too: explanations, historical counts, file
locations, test procedures, links to prior work.

### 3. Nothing became a prerequisite by accident

Useful measurement, a conversation with another team, or a related ticket is a
**prerequisite** only when its result determines whether or how this work can proceed.
Otherwise it is a step inside the work, or simply related.

- A before/after baseline is part of the work. A separate investigation that must conclude
  first is a gate. They read alike and are not alike.
- Signals to check: "we should first…", "once we know…", "ideally after…". Ask what
  changes if the answer comes out the other way. If nothing changes, it isn't a gate.
- **A gate someone recorded deliberately stays.** If a ticket says a measurement must
  happen before the work starts, keep it until the user says otherwise. Removing a
  recorded decision is not a wording change.

### 4. The title names the outcome

Rewrite titles that describe the author's edit rather than the result:
`Add a scope discriminator (SCHEDULE / CUSTOMER)` → `Let a credit grant belong to a
customer rather than a billing schedule`.

A technical mechanism can be a perfectly clear outcome for an engineering ticket. "Reduce
overhead around BigQuery usage-query execution" is a good title. Don't invent customer
impact you can't evidence just to avoid naming the mechanism — where a user-visible cost
is real, put it in the title (`Remove the lock that makes customers wait up to 30 minutes
for credit to apply`); where it isn't, the mechanism is the outcome.

### 5. The people who matter are named

Hunt for unowned phrases — "this makes it findable", "everything else builds on this",
"the dashboard needs it". Ask *what* or *who*, specifically.

Name the users affected, the consumers of the change, and whoever owns an open decision.
Don't list everyone tangentially involved; a roll-call dilutes the two names that matter.

Naming consumers often reveals that some are certain and some are contingent on an open
decision, which sharpens both the justification and the scope boundary. If you can't name
a single concrete consumer, question whether the ticket should exist yet.

### 6. The ticket doesn't promise what it doesn't build

Read the criteria as a stranger. If one implies a capability the scope explicitly defers,
you have a real defect — someone will either build the deferred thing or tick a box that
isn't true. Either bring it into scope or reword it.

Watch for this after any scope change: criteria written before a decision often outlive it.

### 7. Deferrals are interrogated, not inherited

For anything marked blocked or deferred, ask *precisely* what it's waiting on. Bundled
deferrals are common: one part genuinely blocked, another part free, deferred together out
of caution.

Split them. Say what would unblock the remainder, by name — a decision, a person, a
prerequisite ticket. "Waiting on designs" is not a blocker unless you can say which
decision in those designs changes the work.

### 8. Evidence is proportional to the claim

Keep evidence that supports the action, the scope, the risk, or the validation. Cut the
rest — a thorough investigation does not entitle its findings to space in the ticket.

Keep three things apart, in wording and in layout:

- **observed facts** — what was measured, where, and when
- **inferences** — what that probably means
- **expected benefits** — what should happen if the work is done

A dated observation must stay dated. "No usage in production on 27 Aug" must never become
"no usage today", "no risk", or "nothing can break". Expected savings are estimates:
label them as such, give the basis, and say how uncertain they are.

For every figure, quote, and claim, know where it came from and whether it was verified
*now* or inherited from an earlier write-up. Inherited numbers are fine; inherited numbers
presented as current are not. Give an absolute date — "as of 27 Aug", never "recently",
because the ticket outlives the conversation.

Placement follows weight. One dated production finding that justifies the whole ticket
belongs in the opening; the table of every service in the estate belongs below it.

Verify rather than inherit where a tool can settle it — search the codebase for an
identifier, query the database for a count, open the linked PR or document. Doing so
routinely turns up something better than a tidier ticket.

### 9. The ticket states the current position, not its editing history

A ticket is a statement of where things stand. Strip the narrative of how it got there:

- "an earlier draft said…", "this was originally scoped as…"
- approaches that were considered and dropped
- the same correction made three times in different sections
- commentary on the order PRs were raised or reviewed

Keep the corrected fact and its source. Keep a rejected approach only when someone is
likely to reimplement it — then one sentence saying why not, not the debate.

**The exception is irreplaceable evidence.** Incident identifiers, job or run IDs, log
links, timestamps that can't be reconstructed: these stay, even when they look like
history. Losing them costs someone a re-investigation.

### 10. The ticket doesn't contradict itself

Read it top to bottom in one pass. A lead paragraph asserting something a later section
denies is easy to introduce when facts arrive out of order, and it destroys trust in
everything else on the page.

## Never invent

Do not paper over a gap with plausible language — a confident sentence in a ticket becomes
a decision someone else acts on.

Specifically, never:

- invent a file path, endpoint, flag name, table, or identifier — search for it, and if you
  can't find it say so in the ticket
- restate a figure without knowing its source
- assert a decision was made because it seems to follow from what was
- convert someone's proposal into settled fact, or a hedge into a certainty
- guess at intent behind a status change, cancellation, or edit someone else made

When a source hedges, hedge with it, and attribute: "Killian, 27 Aug", "proposed, not
ratified", "assumed unless told otherwise".

An unknown is not a reason to stop. Continue the editorial work that doesn't depend on it —
structure, deletion, dating, wording — and mark the gap in the ticket. Ask only when the
missing answer would change the scope or a consequential claim.

## When to ask rather than decide

Ask when the answer changes the work rather than its wording. Use one round of questions
covering everything open, not a drip of separate ones.

Explicit authorisation you already have counts. If the user asked for a change — including
a retitle, a split, or a status move — do it; don't ask a second time for permission
they've given. The list below applies to changes the user hasn't asked for.

**Ask before:**

- changing status, assignee, priority, milestone, or team — these belong to the user and
  their sprint process
- closing, cancelling, merging, or splitting a ticket
- reversing or removing a decision recorded in a ticket, including a recorded prerequisite
- retitling, if the ticket has been shared, referenced, or has a branch in flight

**Ask when:**

- two readings of the scope would produce materially different work
- a claim can't be traced and matters to the conclusion
- the right home is ambiguous — which milestone, which team, whether it's one ticket or two
- refinement uncovers a defect beyond the ticket's stated scope: report it, don't quietly
  widen the ticket

**Decide yourself, and say what you decided:**

- wording, structure, ordering, what is visible and what is collapsed
- deleting repetition, superseded drafts, and editing history
- correcting a figure you can prove is wrong
- adding a criterion that was clearly implied
- fixing an internal contradiction

## Tooling

Read the stored ticket before judging it and again before writing to it — never refine from
what you remember drafting. Use the tracker's own read/write tools (in Linear, `get_issue`
and `save_issue`) rather than a browser fetch, so you see the raw markdown you're about to
patch.

For test 8, prefer the tool that settles the question over the plausible answer:

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

What stays visible:

- the recommendation
- any unresolved decision, and who owns it
- genuine blockers
- material tradeoffs and risks

What is collapsed: supporting implementation detail, evidence tables, estate statistics,
provenance chains, background someone would only want while implementing.

What is deleted: repetition, superseded drafts, restated context, editing history.

Don't title a collapsible with the heading that precedes it — "Implementation context"
appearing as both a heading and the collapsed section's title tells the reader nothing
twice.

## Write verification

The write is where good refinement is lost. Every time:

1. Re-read the stored ticket immediately before writing — someone may have edited it while
   you worked.
2. Patch only the sections you were asked to change. Don't rewrite a section you weren't
   working on because it was in the same block.
3. Read back the saved ticket after writing.

On the read-back, confirm:

- edits made by other people since you started are still there
- links, ticket references, and unique evidence (run IDs, incident links) survived
- the checklist conditions still say what they said before the save
- every collapsible is paired and closed

## Linear specifics

Collapsible sections are delimited by a line of three `>` characters — one opening the
section with its title, one on its own closing it. **They must be paired.** An unclosed
section is parsed as a nested blockquote and renders as mangled indented text.

Linear rewrites some markdown on save — ticket references become link elements, for one —
so a targeted patch may fail to match text you wrote moments earlier. Re-read the stored
description before patching, or replace it wholesale.

## Batches

When refining more than one ticket, the set has defects the individual tickets don't:

- **Overlapping scope.** Two tickets touching the same code are not automatically one
  ticket. Merge-worthy overlap looks like: the same outcome claimed twice, ownership that
  can't be split, or work that can't be delivered separately. Report it; don't merge unasked.
- **Inconsistent terminology.** The same concept named three ways across a batch reads as
  three concepts. Pick the one the domain already uses and say which you standardised on.
- **Dependency order.** If B can't start until A lands, say so in B, naming A. Check the
  batch is orderable at all — a cycle means the split is wrong. Apply test 3 here too:
  sequencing a batch is not a reason to invent gates between its tickets.
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

Report, per ticket, a compact summary of what changed — a few lines, not a diff. Routine
wording, ordering and deletion do not each need a justification.

Explain only the judgement calls that someone might reasonably want to reverse:

- the ticket type you decided it was, if that changed what "done" means
- content you deleted rather than collapsed
- something you demoted from prerequisite to step, or promoted the other way
- factual errors corrected
- claims that remain unverified
- defects the review exposed that need a decision
- anything another person changed while you were working, without reverting it

Say plainly when a ticket needed nothing.

If the tickets are mirrored anywhere — a planning doc, a scoping ticket, a project page —
say that it now needs updating. Don't update it unasked.

## Cross-team tickets

Name the other team's dependency explicitly, and say whether it's a genuine handoff or
something the owning team could absorb. Default to describing the shape of the dependency
and who to ask, rather than asserting a handoff that hasn't been agreed.

Never raise or edit a ticket in another team's area on their behalf without being asked.
