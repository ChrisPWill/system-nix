# Graphiti memory

A [Graphiti](https://github.com/getzep/graphiti) knowledge graph that Claude Code and Codex share over MCP at `http://127.0.0.1:8000/mcp/`. The agent-facing rules are in `../../shared-rules/graphiti-memory.md`.

Enable per host with `services.graphiti.enable = true;`. This is macOS only for now.

## How it runs

```
launchd: ollama  ──  native, Metal GPU, 127.0.0.1:11434
launchd: graphiti ── docker-compose (Colima) ── zepai/knowledge-graph-mcp
                     FalkorDB + MCP server in one container
                     reaches Ollama via host.docker.internal
```

- **Models:** the `ollama-pull-models` agent pulls them at login. The first run downloads about 19 GB.
- **Data:** stored in `~/.local/share/graphiti/falkordb`. Back up that directory to back up the graph.
- **Config:** `config.yaml` fixes the structure; every value comes from Nix options in `default.nix`.

## Operations

| Task                  | Command                                                               |
| --------------------- | --------------------------------------------------------------------- |
| Status                | `graphiti-status`                                                     |
| Logs                  | `tail -f ~/Library/Logs/graphiti.launchd.log`                         |
| Restart               | `launchctl kickstart -k gui/$(id -u)/org.nix-community.home.graphiti` |
| Stop until next login | `launchctl bootout gui/$(id -u)/org.nix-community.home.graphiti`      |

## Changing models

- **LLM:** change `services.graphiti.llmModel` freely. It only affects episodes ingested afterwards.
- **Embedder:** changing `services.graphiti.embedder.*` makes every existing vector incompatible. Stop the agent, delete the data directory, and re-ingest.

## Upgrading the image

The image is pinned by digest in `default.nix`. Read the upstream release notes before bumping it, because FalkorDB data written by a newer Graphiti may not be readable by an older one.
