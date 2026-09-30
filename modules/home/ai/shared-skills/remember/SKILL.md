---
name: remember
description: Save a durable fact, decision or debugging discovery to the shared Graphiti memory so later Claude Code and Codex sessions can find it. Use when you uncover an architectural decision, domain invariant or non-obvious root cause, when the user states a convention that applies beyond the current task, when correcting an outdated memory, or when invoked as /remember <fact>.
---

# Remember

Saves an episode to the Graphiti knowledge graph that Claude Code and Codex share. If no `graphiti` MCP tools are available, tell the user the memory couldn't be saved.

## 1. Decide whether it belongs

Save it only if all of these hold:

- It will still be true and useful in a month.
- It isn't already recorded in the repository. If it belongs in the code or docs, suggest putting it there instead.
- It contains no secrets, credentials or customer data.

When the user invokes `/remember` explicitly, their judgement stands. Still point out anything secret or clearly transient.

## 2. Choose the group

Use the Groups table in the shared memory rules. If nothing fits, propose a new `<scope>-<domain>` name to the user and wait for their answer; don't create groups silently.

## 3. Check for duplicates

Run `search_memory_facts` for the fact in the chosen group.

- Already there and still current: don't save it again. Tell the user it's already known.
- There but outdated or wrong: save the corrected version. Graphiti marks the old fact as superseded. Don't delete the old one.

## 4. Write the episode

Call `add_memory` with:

- `name`: a short title, e.g. "Invoice immutability after finalization".
- `episode_body`: one topic, a few sentences, standing alone. Name the repository, service and entities explicitly, and include the reason, not just the fact. The local extraction model handles short, focused episodes far better than long ones, so split unrelated facts into separate calls.
- `group_id`: the chosen group.
- `source`: `text`.
- `source_description`: where it came from, e.g. "debugging session in sequence-platform-api" or "stated by user".
- `reference_time`: only when the fact became true at a known earlier time, e.g. the date of a decision. Use ISO-8601.

A good episode body:

> In sequence-platform-api, finalized invoices are immutable. Corrections are recorded as adjustment entries against the ledger rather than by editing the invoice, because the ledger must stay auditable.

## 5. Confirm

`add_memory` only queues the episode; extraction runs in the background and takes 30 seconds or more. Tell the user what was saved and to which group. Don't wait for extraction, and don't re-add it if an immediate search doesn't find it.
