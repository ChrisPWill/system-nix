# Shared Memory (Graphiti)

These rules apply only when a `graphiti` MCP server is available. It is a knowledge graph shared between Claude Code and Codex, so anything saved there will be read later by a different agent with none of the current context.

## Reading

- Before making architectural or domain assumptions, search Graphiti for existing facts and decisions (`search_nodes`, `search_memory_facts`).
- Treat results as leads, not truth. Repository code, docs and ADRs win when they conflict with Graphiti. When they do, say so, and record the correction as a new episode.

## Writing

Save with `add_memory` only when the information is durable and not already recorded in the repository:

- architectural decisions and their rationale
- domain invariants and important relationships between concepts
- non-obvious debugging discoveries, such as root causes and misleading symptoms
- conventions stated by the user that apply beyond the current task

Do not save:

- transient task state, plans or progress
- facts that the code or git history already makes obvious
- conversation transcripts or summaries of whole sessions
- secrets, credentials or customer data

Write each episode so it stands alone. Name the repository, service and entities explicitly, and include the reason, not just the fact. For example: "In sequence-platform, finalized invoices are immutable; corrections are adjustment entries, because the ledger must stay auditable."

## Groups

- Pass an explicit `group_id` named `<scope>-<domain>`, such as `sequence-billing`, `sequence-integrations` or `personal-engineering`.
- Reuse an existing group before inventing a new one. Search first to see which groups hold related facts.
- Omit `group_id` only for knowledge that spans domains; the server then uses its default group.
- Never use `main`.

## Destructive tools

Never call `clear_graph`, `delete_episode` or `delete_entity_edge` unless the user explicitly asks. Correct outdated facts by adding a new episode; Graphiti marks the old fact as superseded and keeps its history.
