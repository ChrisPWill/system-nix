---
name: explain
description: Explain a change in plain, low-density language — what was broken, why, how it was fixed, and what else improved. Use when asked to explain, summarise or ELI5 a PR, branch, diff or "what we just did", when someone asks for a "monkey brain" or non-technical version, wants it in N words, or in a particular voice (including their own).
argument-hint: "[pr-number|url|branch|'what we just did'] [word-cap] [eli5] [voice=<me|persona>]"
---

# Explain

Turn a change into something a tired human understands in one read. The bar is the
user's own prompt: "summarise in terms my monkey brain would understand exactly what
the issue is that this PR fixes, and how it fixed it (including any improvements)".

The output is the explanation, in chat. Never post it to GitHub, Slack, a ticket or
anywhere else.

## Arguments

Parse `$ARGUMENTS` loosely; order doesn't matter.

- **Target** — a PR number or URL, a branch, a revision range, or "what we just did"
  (the work in this conversation). If none is given, use the conversation's work if
  there is some, otherwise the current branch's PR (`gh pr status`). Ask if it's still
  ambiguous rather than guessing a PR number.
- **Word cap** — a bare number (`25`, `50`) or "max 50 words". It is a hard limit:
  count the words before answering and cut until it fits. Keep the symptom and the
  fix; drop extras first, then the mechanism.
- **`eli5`** — no jargon at all. Replace every technical term with what it does
  ("the bit that sorts changes into piles", not "the classifier"). Analogies are fine
  if they stay accurate.
- **`voice=<x>`** — see Voice below. Without it, write in plain voice.

## Gather the facts

Read the change itself; a description is a claim, not evidence.

- **PR** — `gh pr view <target> --json title,body,headRefName,baseRefName,files,comments,reviews`
  and `gh pr diff <target>`. Skim linked ticket and test names when they show the
  symptom or the scenario more clearly than the code does.
- **Branch or diff** — `jj diff -r <rev>` / `jj log`, or `git diff <base>...<branch>`
  and `git log`.
- **"What we just did"** — the conversation, checked against the current diff.

Check anything you're about to state against the code: the actual condition that was
wrong, the actual numbers in tests or fixtures. If the PR description and the code
disagree, trust the code and mention the gap. Never invent figures; if no concrete
example exists, describe the case in words instead.

## Structure

In this order, as short prose (no headings, no bullets unless asked):

1. **What was broken** — the symptom a person would notice: a customer, a user, the
   on-call engineer. Not the code smell. For a feature or refactor there's nothing
   broken; say what was missing or painful instead.
2. **Why it happened** — one or two sentences on the mechanism, with the minimum
   jargon needed to be true.
3. **How it was fixed** — what behaves differently now, with the concrete outcome.
4. **Extras** — tests added, hardening, follow-ups raised in review. Only if there are
   any.

Drop any part that doesn't apply. Prefer concrete numbers and a worked example over
abstractions: "pays £6,500" beats "is charged correctly".

Target density, plain voice, no cap:

> A customer who downgrades and extends their contract in the same edit got charged
> the new price but never refunded the old one, so they paid twice. The system sorts
> changes into categories; the category that moves the end date never received the
> split date, so it threw the refund away. Now both categories get the split date: the
> £1,600 refund goes out as a credit note and the customer pays £6,500, what they owe.
> Three end-to-end tests cover it. Review comments also suggest making the category
> list impossible to get wrong next time.

Note what it does: one sentence per part, a real customer action, real amounts, and
the internal mechanism named by what it does rather than its class name.

## Voice

Voice changes how it sounds, never what it says. Facts, numbers and caveats survive
every voice.

**`voice=me`** (or "in my voice") — write as the user would say it.

- Don't sample their GitHub PR descriptions or comments: many were written by an
  agent, so they'd teach you your own style back.
- Sample their Slack messages: search with the Slack MCP tools (load them via
  ToolSearch if deferred), e.g. `from:<user>` across a few channels, for roughly
  20–40 messages of varied length.
- Sample 2–3 Granola meeting transcripts (list meetings, then
  `get_meeting_transcript`) and use only the lines the user spoke.
- Extract traits: sentence length, vocabulary, spelling (British or not), humour,
  how they hedge or emphasise, how they open and close. Apply those; don't quote or
  reveal anything private from the samples in the output.
- If the Slack or Granola tools aren't available (for example in Codex), say so in one
  line and use plain voice rather than guessing at their style.

**Any other voice** (a character, a persona, "pirate", "BBC newsreader") — apply it as
a style. Keep it readable; if the voice fights the word cap, the cap wins.

## Before answering

- Word cap respected (count it).
- Every number and claim traceable to the diff, tests or ticket.
- No unexplained jargon at `eli5`; at most a term or two otherwise.
- Nothing posted anywhere.
