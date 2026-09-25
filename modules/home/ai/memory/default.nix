# Durable memory shared across coding agents. Backends live in their own
# subdirectories so the agent-facing interface (an MCP server) can outlive
# any one tool.
{
  imports = [
    ./graphiti
  ];
}
