---
name: recall
description: Search the shared Graphiti memory for decisions, domain facts and debugging discoveries saved by earlier Claude Code or Codex sessions. Use at the start of a task in a repository, before making an architectural or domain assumption, when the user asks what is known about a topic, or when invoked as /recall <topic>.
---

# Recall

Searches the Graphiti knowledge graph that Claude Code and Codex share. If no `graphiti` MCP tools are available, say so if the user asked explicitly; otherwise carry on without it.

## 1. Choose the groups

Pick every group from the Groups table in the shared memory rules that could plausibly hold the answer. Usually that means the group for the current domain plus `sequence-platform` for cross-cutting knowledge.

Always pass `group_ids` as a list. Omitting it searches only the server's default group.

## 2. Search

Run both searches, since they return different things:

- `search_memory_facts`: relationships and decisions, e.g. "finalized invoices are immutable". This is usually the more useful one.
- `search_nodes`: entities and their summaries, e.g. what `LedgerEntry` is.

Phrase the query the way the fact would be written ("invoice correction after finalization"), not as a question. Use the domain nouns from the task.

If a result names an entity that matters, search again with `center_node_uuid` set to its UUID. That ranks facts around that entity higher.

## 3. Read the results critically

- Ignore facts with `invalid_at` set, unless the history itself is relevant; then describe them as superseded.
- Check anything you'll rely on against the repository. Code, docs and ADRs win. If Graphiti is wrong, say so and use the `remember` skill to record the correction.
- If nothing comes back, say so plainly. An empty result is useful information, not a failure.

## 4. Report

For the user, report the relevant facts briefly, each with its group and a note if you verified it against the code. For your own task, carry the facts forward as context; don't repeat them back unless asked.
