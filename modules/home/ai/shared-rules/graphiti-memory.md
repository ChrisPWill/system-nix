# Shared Memory (Graphiti)

These rules apply only when a `graphiti` MCP server is available. It is a knowledge graph shared between Claude Code and Codex, so anything saved there will be read later by a different agent with none of the current context.

Use the `recall` skill to search it and the `remember` skill to save to it. They hold the procedures; this file says when to use them.

## When to recall

- At the start of any task in a repository, run one search using the task's key terms.
- Before making an architectural or domain assumption that the code doesn't settle.
- When the user asks what is known about something.

Treat results as leads, not truth. Repository code, docs and ADRs win when they conflict with Graphiti. When they do, say so, and record the correction with `remember`.

## When to remember

Save only when the information is durable and not already recorded in the repository:

- architectural decisions and their rationale
- domain invariants and important relationships between concepts
- a root cause that wasn't obvious from the code; save it before moving on, not at the end of the session
- conventions the user states that apply beyond the current task

Do not save:

- transient task state, plans or progress
- facts that the code or git history already makes obvious
- conversation transcripts or summaries of whole sessions
- secrets, credentials or customer data

## Groups

Each `group_id` is a separate graph. Known groups:

| Group                   | Holds                                                                      |
| ----------------------- | -------------------------------------------------------------------------- |
| `sequence-platform`     | Cross-cutting Sequence architecture and conventions (the server's default) |
| `sequence-billing`      | Billing, invoicing, ledger and revenue domain                              |
| `sequence-integrations` | Third-party integrations and webhooks                                      |
| `personal-engineering`  | Personal projects and general engineering knowledge                        |

- Always pass `group_ids` explicitly when searching. Omitting it searches only the default group, not all of them.
- The server cannot list groups, so this table is the registry. If no group fits, propose a new `<scope>-<domain>` name to the user rather than creating one silently.
- Never use `main`.

## How the server behaves

- `add_memory` returns immediately and extracts in the background, which takes 30 seconds or more with the local model. An episode won't appear in search straight away. Don't re-add it; check with `get_episodes` if needed.
- Pending episodes are held in memory, so a server restart can drop one that hasn't been processed yet.
- Facts with `invalid_at` set have been superseded. Don't present them as current.

## Destructive tools

Never call `clear_graph`, `delete_episode` or `delete_entity_edge` unless the user explicitly asks. Correct outdated facts by adding a new episode; Graphiti marks the old fact as superseded and keeps its history.
