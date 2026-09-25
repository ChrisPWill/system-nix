{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.graphiti;

  # Pinned by digest so a flake update never silently changes the schema of
  # stored data; bump deliberately after reading upstream release notes.
  image = "zepai/knowledge-graph-mcp:1.1.0@sha256:a2536b6d59b4afb359a13aeaa4a9d2f4db195af14231168efda6a3d166228956";

  project = "graphiti";
  mcpUrl = "http://127.0.0.1:${toString cfg.port}/mcp/";
  dockerHost = "unix://${config.home.homeDirectory}/.colima/default/docker.sock";

  # Colima only shares $HOME with its VM, so bind-mount sources must live
  # there; a /nix/store path would appear as an empty directory in the container.
  mountedConfig = "${config.xdg.dataHome}/graphiti/config.yaml";

  composeFile = (pkgs.formats.yaml {}).generate "graphiti-compose.yaml" {
    name = project;
    services.graphiti = {
      inherit image;
      environment = {
        CONFIG_PATH = "/app/mcp/config/config.yaml";
        MODEL_NAME = cfg.llmModel;
        EMBEDDER_MODEL = cfg.embedder.model;
        EMBEDDER_DIMENSIONS = toString cfg.embedder.dimensions;
        # host.docker.internal reaches the host's loopback through Colima, so
        # Ollama never has to listen beyond 127.0.0.1.
        OPENAI_API_URL = "http://host.docker.internal:11434/v1";
        # Graphiti refuses to start without a key; Ollama ignores it.
        OPENAI_API_KEY = "ollama";
        GRAPHITI_GROUP_ID = cfg.defaultGroupId;
        # A local model serves requests roughly one at a time; more in-flight
        # episodes only turn into timeouts.
        SEMAPHORE_LIMIT = toString cfg.concurrency;
        GRAPHITI_TELEMETRY_ENABLED = "false";
        BROWSER = "0";
      };
      extra_hosts = ["host.docker.internal:host-gateway"];
      ports = ["127.0.0.1:${toString cfg.port}:8000"];
      volumes = [
        "${mountedConfig}:/app/mcp/config/config.yaml:ro"
        "${cfg.dataDir}:/var/lib/falkordb/data"
      ];
    };
  };

  # Keeps compose attached so launchd owns the lifecycle: stopping the agent
  # stops the container, and there is no `restart:` policy to fight it.
  #
  # The image daemonises FalkorDB (Redis) with default snapshotting and only
  # forwards SIGTERM to the MCP server, so Redis is killed without a final
  # save. Low-volume, curated writes could then sit unsaved for up to an hour.
  # Hence the tighter snapshot interval and the explicit SAVE before stopping.
  runGraphiti = pkgs.writeShellApplication {
    name = "graphiti-run";
    runtimeInputs = [pkgs.docker-compose pkgs.curl pkgs.coreutils];
    runtimeEnv.DOCKER_HOST = dockerHost;
    text = ''
      compose() { docker-compose -f ${composeFile} "$@"; }
      redis() { compose exec -T graphiti redis-cli "$@"; }

      # Colima's agent starts at the same login, so the socket may not exist yet.
      until curl -fsS --unix-socket "''${DOCKER_HOST#unix://}" http://docker/_ping >/dev/null 2>&1; do
        sleep 2
      done
      mkdir -p ${lib.escapeShellArg cfg.dataDir}
      install -D -m 0644 ${./config.yaml} ${lib.escapeShellArg mountedConfig}

      shutdown() {
        redis SAVE >/dev/null || echo "graphiti: final FalkorDB save failed" >&2
        compose stop
        exit 0
      }
      trap shutdown TERM INT

      compose up --remove-orphans &
      up_pid=$!

      until redis PING >/dev/null 2>&1; do
        kill -0 "$up_pid" 2>/dev/null || { wait "$up_pid"; exit $?; }
        sleep 2
      done
      redis CONFIG SET save "60 1" >/dev/null

      wait "$up_pid"
    '';
  };

  graphitiStatus = pkgs.writeShellApplication {
    name = "graphiti-status";
    runtimeInputs = [pkgs.docker-compose pkgs.curl];
    runtimeEnv.DOCKER_HOST = dockerHost;
    text = ''
      echo "== health (${mcpUrl})"
      curl -fsS --max-time 5 http://127.0.0.1:${toString cfg.port}/health && echo || echo "unreachable"
      echo "== container"
      docker-compose -f ${composeFile} ps
      echo "== ollama models loaded"
      curl -fsS --max-time 5 http://127.0.0.1:11434/api/ps || echo "ollama unreachable"
      echo
      echo "logs: ~/Library/Logs/graphiti.launchd.log"
    '';
  };
in {
  options.services.graphiti = {
    enable = lib.mkEnableOption "Graphiti knowledge-graph memory shared by coding agents over MCP";

    port = lib.mkOption {
      type = lib.types.port;
      default = 8000;
      description = "Loopback port for the MCP HTTP endpoint.";
    };

    llmModel = lib.mkOption {
      type = lib.types.str;
      # MoE: ~30B-class extraction quality with only ~3B active parameters, so
      # ingestion stays fast. The instruct (non-thinking) variant keeps
      # <think> blocks out of the JSON Graphiti has to parse.
      default = "qwen3:30b-a3b-instruct-2507-q4_K_M";
      description = "Ollama model used for entity extraction, deduplication and fact invalidation.";
    };

    embedder = {
      model = lib.mkOption {
        type = lib.types.str;
        default = "nomic-embed-text";
        description = ''
          Ollama embedding model. Changing it (or its dimensions) invalidates
          every stored vector, so the graph must be rebuilt afterwards.
        '';
      };
      dimensions = lib.mkOption {
        type = lib.types.int;
        default = 768;
        description = "Output dimensions of the embedding model.";
      };
    };

    defaultGroupId = lib.mkOption {
      type = lib.types.str;
      default =
        if config.isWorkMachine
        then "sequence-platform"
        else "personal-engineering";
      description = "Graph partition used when an agent does not pass a group_id.";
    };

    concurrency = lib.mkOption {
      type = lib.types.ints.positive;
      default = 2;
      description = "Episodes processed in parallel (Graphiti's SEMAPHORE_LIMIT).";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.xdg.dataHome}/graphiti/falkordb";
      description = "Host directory holding FalkorDB's persisted graph.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        # Linux needs a different route from the container to a loopback-only
        # Ollama (no Colima host forwarding), plus a systemd unit. Deferred
        # until a Linux host actually wants this.
        assertion = pkgs.stdenv.hostPlatform.isDarwin;
        message = "services.graphiti currently supports macOS (Colima) only.";
      }
    ];

    services.local-ollama = {
      enable = true;
      models = [cfg.llmModel cfg.embedder.model];
      # Extraction prompts carry existing entities alongside the episode, so
      # they outgrow Ollama's default window quickly.
      contextLength = lib.mkDefault 16384;
      # Frees ~19GB of unified memory between bursts of ingestion; reloading
      # is only reads, and usually served from the page cache anyway.
      keepAlive = lib.mkDefault "10m";
    };

    home.packages = [graphitiStatus];

    launchd.agents.graphiti = {
      enable = true;
      config = {
        ProgramArguments = [(lib.getExe runGraphiti)];
        RunAtLoad = true;
        KeepAlive = {
          SuccessfulExit = false;
        };
        EnvironmentVariables.HOME = config.home.homeDirectory;
        StandardOutPath = "${config.home.homeDirectory}/Library/Logs/graphiti.launchd.log";
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/graphiti.launchd.log";
      };
    };

    programs.mcp = {
      enable = true;
      servers.graphiti.url = mcpUrl;
    };
    programs.claude-code.enableMcpIntegration = true;

    # Not programs.codex.enableMcpIntegration: that makes Home Manager own
    # ~/.codex/config.toml, which Codex itself keeps writing to (project trust,
    # hook hashes, plugins). Registering through Codex's own CLI edits just this
    # entry. The guard matters: every `add` re-serialises the whole
    # [mcp_servers] table, so it should only run when the entry is missing or stale.
    home.activation.registerGraphitiWithCodex = lib.mkIf config.programs.codex.enable (
      lib.hm.dag.entryAfter ["writeBoundary"] ''
        codex=${lib.getExe config.programs.codex.package}
        current=$($codex mcp get graphiti --json 2>/dev/null | ${lib.getExe pkgs.jq} -r '.transport.url // empty' || true)
        if [ "$current" != ${lib.escapeShellArg mcpUrl} ]; then
          run $codex mcp add graphiti --url ${lib.escapeShellArg mcpUrl}
        fi
      ''
    );
  };
}
